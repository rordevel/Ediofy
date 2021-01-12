require 'pg'
include ActionView::Helpers::SanitizeHelper

namespace :question_import do

  desc 'Import Question from Imeducate'
  task :import => :environment do
    host = ENV['host']
    port = ENV['port'].to_i
    dbname = ENV['dbname']
    user = ENV['user']
    password = ENV['password']

    import_users = User.where("full_name in (?)", ['Haley Thompson', 'Christopher Peyton', 'Rodney Peyton', 'Martin Hassan'])
    if import_users.count > 0
      conn = PG::Connection.new(:host => host, :port => port, :dbname => dbname, :user => user, :password => password)
      # conn = PG::Connection.new(:host => 'localhost', :port => 5432, :dbname => 'imeducate', :user => 'root', :password => 'root')
      res = conn.exec_params('SELECT * from questions order by id asc')
      res.each do |r|
        import_user = import_users[(0..import_users.count-1).to_a.sample]
        puts "****************** Name =   #{import_user.first_name} *****************"
        body = explanation = locale = tag_list = ''
        answers_attributes = {}
        references_attributes = {}
        q_id = r['id']
        puts "Question id = #{q_id}"
        translation = conn.exec_params('SELECT * from question_translations where question_id='+q_id)
        translation.each do |t|
          body        = strip_tags(t['body'])
          explanation = strip_tags(t['explanation'])
          locale      = t['locale'] rescue 'en'
        end
        puts "Body = #{body}"
        puts "Explanation = #{explanation}"
        puts "Locale = #{locale}"

        puts "******** Tags **********"
        tags = conn.exec_params('SELECT topics.title from topics,topic_questions where topic_questions.question_id='+q_id+' and topics.id = topic_questions.topic_id')
        tag_list = tags.collect{|a| a['title']}.join(',')
        puts tag_list

        puts "References"
        references = conn.exec_params('SELECT title, url from "references" where referenceable_id = '+ q_id)
        references.each_with_index do |reference, index|
          references_attributes[index.to_s] =  reference
        end
        puts references_attributes

        puts "********* Answers ***********"
        answers = conn.exec_params('SELECT answers.correct, answer_translations.body from answers, answer_translations where answers.id in (select id from answers where question_id ='+q_id+') and answers.id = answer_translations.answer_id')
        answers.each_with_index { |answer, index| answers_attributes[index.to_s] = answer }
        puts answers_attributes

        # import record
        question = import_user.questions.new(:body => body, :explanation => explanation, :tag_list => tag_list, :locale => locale, :answers_attributes => answers_attributes, :references_attributes => references_attributes)
        question.approved = true
        question.save(:validate => false)
      end
    else
      puts "******* No import user is available ***************"
    end
  end
end
