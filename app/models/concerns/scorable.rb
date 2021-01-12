module Scorable

  extend ActiveSupport::Concern

  included do
    after_save :update_score!

    def self.avg_num_votes
      Rails.cache.fetch "avg_number_of_votes_per_obj", expires_in: 1.day do
        classStr = class_name.to_s
        votes_per_obj = ActsAsVotable::Vote.group{votable_id}.where(votable_type: classStr).select{'count(*) as count_all'}.map(&:count_all).map(&:to_i)
        votes_per_obj.inject{ |sum, el| sum + el.to_i }.to_f / votes_per_obj.size
      end
    end

    def self.avg_score
      Rails.cache.fetch "avg_score_per_voted_obj", expires_in: 1.day do
        scores_per_obj = joins{votes}.select('score').map(&:score).map(&:to_f)
        scores_per_obj.inject{ |sum, el| sum + el.to_f }.to_f / scores_per_obj.size
      end
    end
  end

  def current_score
    tally_ci_lower_bound() / (days_since+1.to_f ** 0.2)
  end

  def update_score!
    update_column(:score, current_score)
    # TOD0: Commented out for the time being as it has issue with ActsAsTaggable
    # self.reload
  end

  def days_since
    ((Time.now.to_i - created_at.to_i)/(60*60*24))
  end

  def rating
    if score
      (score * 100).round(2)
    end
  end

  # Adapted from: http://evanmiller.org/how-not-to-sort-by-average-rating.html
  def tally_ci_lower_bound(pos = count_votes_up, n = self.votes_for.count, power = 0.95)
    return 0 if n == 0

    z = pnorm(1-(1-power)/2)

    phat = 1.0*pos/n
    num = (phat*(1-phat)+z*z/(4*n))/n

    (phat + z*z/(2*n) - z * Math.sqrt(num))/(1+z*z/n)
  end

  private

  def the_only_votes_are_negative?
    !votes.empty? && up_votes.empty?
  end

  # https://github.com/abscondment/statistics2/blob/master/lib/statistics2/base.rb
  # inverse of normal distribution ([2])
  # Pr( (-\infty, x] ) = qn -> x
  def pnorm(qn)
    b = [1.570796288, 0.03706987906, -0.8364353589e-3,
         -0.2250947176e-3, 0.6841218299e-5, 0.5824238515e-5,
         -0.104527497e-5, 0.8360937017e-7, -0.3231081277e-8,
         0.3657763036e-10, 0.6936233982e-12]

    if(qn < 0.0 || 1.0 < qn)
      $stderr.printf("Error : qn <= 0 or qn >= 1  in pnorm()!\n")
      return 0.0;
    end
    qn == 0.5 and return 0.0

    w1 = qn
    qn > 0.5 and w1 = 1.0 - w1
    w3 = -Math.log(4.0 * w1 * (1.0 - w1))
    w1 = b[0]
    1.upto 10 do |i|
      w1 += b[i] * w3**i;
    end
    qn > 0.5 and return Math.sqrt(w1 * w3)
    -Math.sqrt(w1 * w3)
  end

end
