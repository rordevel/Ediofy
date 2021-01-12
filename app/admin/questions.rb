ActiveAdmin.register Question do
  menu priority: 2
  permit_params :active, :body, :explanation, :difficulty, :question_image, references_attributes: [:id, :title, :url, :_destroy], 
      correct_answers_attributes: [:id, :body, :correct, :_destroy],
      incorrect_answers_attributes: [:id, :body, :correct, :_destroy],
      tag_ids: []

  form do |f|
    tabs do
      tab "Question Details" do
        f.inputs do
          f.input :active, as: :select
          f.input :body
          f.input :explanation
          f.input :question_image, hint: (f.object.question_image.blank?) ? "" : image_tag(f.object.question_image.url(:preview))
          f.input :difficulty, as: :select, :collection => Question::DIFFICULTY, :include_blank => false
          f.has_many :references, allow_destroy: true do |r|
            r.input :title
            r.input :url
          end
        end    
      end
      tab "Answers" do
        correct = f.object.correct_answers.blank? ? f.object.correct_answers.new : f.object.correct_answers.last
        f.semantic_fields_for :correct_answers, correct do |a|
          a.input :body, label: "Correct Answer"
          # a.input :correct
        end
        f.has_many :incorrect_answers do |a|
          a.input :body, label: "Incorrect Answer"
          # a.input :correct
        end
      end
    end
    f.actions
  end
  show do
    attributes_table do
      row :user
      row :active
      row "Body" do |q|
        q.body.html_safe
      end
      row "Explanation" do |q|
        q.explanation.html_safe
      end
      row :difficulty
      row "Image" do |q|
        image_tag(q.question_image.url(:preview)) if q.question_image?
      end
      panel "Answers" do
        ul do
          question.answers.each do |a|
            output = a.body.html_safe
            li class: "#{'correct' if a.correct? }" do
              output
            end
          end
        end  
      end
      panel "References" do
        ul do
          question.references.each do |r|
            li do
              link_to r.title, r.url
            end
          end
        end  
      end
      panel "Tags" do
        ul do
          question.tags.each do |t|
            li t&.name
          end
        end
      end
    end
  end 
  filter :user
  filter :difficulty, as: :select
  filter :active, as: :select
  filter :approved, as: :select
  filter :score
  filter :private
  filter :status, as: :select, collection: Question.statuses
  filter :tags
  filter :media
  filter :references
  filter :created_at
  filter :updated_at
end