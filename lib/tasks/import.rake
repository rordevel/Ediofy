require 'csv'
require 'import_media'

namespace :import do

  desc 'Import media from CSV'
  task :media, [:filename] => :environment do |t,args|
    args.with_defaults( filename: "" )

    unless args[:filename].to_s == ""
      importer = Import::Media.new(args[:filename])
      importer.import
    else
      puts "Filename required"
    end
  end

  desc 'Import Muscle Anatomy Questions'
  task muscles_anatomy_questions: :environment do

    csv_file = File.open(Rails.root.join('import_data', 'muscles_anatomy_questions.csv'))

    product  = Product.where(title: 'McGraw-Hill Demonstration').first
    product  = Product.create!(title: 'McGraw-Hill Demonstration', short_title: 'MGH', description: 'Demonstration McGraw-Hill Exam', active: false, monthly_price_in_cents: 0) if product.blank?

    topic    = Topic.where(title: 'Anatomy', product_id: product.id).first
    topic    = Topic.create!(title: 'Anatomy', product_id: product.id) if topic.blank?

    subject  = Subject.where(title: 'Muscles', topic_id: topic.id).first
    subject  = Subject.create!(title: 'Muscles', topic_id: topic.id) if subject.blank?

    source   = QuestionSource.where(title: 'McGraw-Hill').first
    source   = QuestionSource.create!(title: 'McGraw-Hill') if source.blank?

    CSV::Reader.parse(csv_file) do |row|
      next if row[0] == 'Question' || row[0].blank? # Skip the top row and any rows with a blank question

      question = Question.new(body: row[0], explanation: row[8].try(:strip).presence, question_source_id: source.id, active: true)
      question.subjects << subject
      question.save!

      correct_answer = row[7].strip.downcase

      answer_a = question.answers.create!(body: row[1], correct: correct_answer == 'a') if row[1].present?
      answer_b = question.answers.create!(body: row[2], correct: correct_answer == 'b') if row[2].present?
      answer_c = question.answers.create!(body: row[3], correct: correct_answer == 'c') if row[3].present?
      answer_d = question.answers.create!(body: row[4], correct: correct_answer == 'd') if row[4].present?
      answer_e = question.answers.create!(body: row[5], correct: correct_answer == 'e') if row[5].present?
      answer_f = question.answers.create!(body: row[6], correct: correct_answer == 'f') if row[6].present?

    end
  end


  desc 'Import questions for September 2011'
  task import_september_2011_questions: :environment do

    Dir[Rails.root.join('import_data/September-2011/**/*.csv')].each do  |file_path|

      # The four lines below turn our CSV into an array of hashes
      csv_data        = CSV.read(file_path)
      headers         = csv_data.shift.map {|i| i.to_s }
      string_data     = csv_data.map {|row| row.map {|cell| cell.to_s } }
      question_data   = string_data.map {|row| Hash[*headers.zip(row).flatten] }

      question_data.each do |question_info|

        # Skip over inputs without a Product
        next unless question_info.has_key?('Product') && question_info.has_key?('Topic')

        product = Product.where(title: question_info['Product']).first
        product = Product.create!(title: question_info['Product'], short_title: ('A'..'Z').to_a.sample, description: 'description', active: false, monthly_price_in_cents: 0, trial_period: 0) if product.blank?

        topic   = Topic.where(title: question_info['Topic'], product_id: product.id).first
        topic   = Topic.create!(title: question_info['Topic'], product_id: product.id) if topic.blank?

        subjects = []

        # Loop through each subject
        question_info['Subject'].split(',').each do |subject_title|
          subject_title.strip!

          subject = Subject.where(title: subject_title, topic_id: topic.id).first
          subject = Subject.create!(title: subject_title, topic_id: topic.id) if subject.blank?

          subjects << subject
        end

        source = QuestionSource.where(title: question_info['Source']).first
        source = QuestionSource.create!(title: question_info['Source']) if source.blank?

        question = Question.joins([:translations, :subjects]).where('question_translations.body' => question_info['Body'], 'subjects.id' => subjects.first.try(:id)).first
        if question.blank?
          question = Question.new(body: question_info['Body'], explanation: question_info['Explaination'].try(:strip).presence, question_source_id: source.id, difficulty: question_info['Difficulty'], active: true)
          question.subjects = subjects
          question.save!
        end

        # Determine the correct answer
        correct_answer = question_info['Correct'].strip.upcase

        # Create all of our answers (if there are non for the question)
        if question.answers.blank?
          ('A'..'F').each do |letter|
            if question_info[letter].present?
              question.answers.create!(body: question_info[letter], correct: correct_answer == letter)
            end
          end
        end
      end
    end
  end
end
