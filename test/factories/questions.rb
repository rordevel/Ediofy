FactoryBot.define do
  factory :question do
    title { 'Question Title' }
    body { 'Question text' }
    explanation { 'Question explanation' }
    approved { true }
    answers_attributes do
      [
        { body: 'Answer 1' },
        { body: 'Answer 2', correct: true },
        { body: 'Answer 3' },
      ]
    end
    user
  end
end
