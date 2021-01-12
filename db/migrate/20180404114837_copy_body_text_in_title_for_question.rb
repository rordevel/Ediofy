class CopyBodyTextInTitleForQuestion < ActiveRecord::Migration[5.0]
  def up
    questions = Question.all
    questions.each do |q|
      if q.title.nil?
        puts "Question id = #{q.id}"
        unless q.body.nil?
          q.title = q.body.length >= 50 ? q.body.truncate(53) : q.body
          q.save(:validate => false)
        end
      end
    end
  end

  def down
    # questions = Question.all
    # questions.each do |q|
    #   q.title = nil
    #   q.save(:validate => false)
    # end
  end
end
