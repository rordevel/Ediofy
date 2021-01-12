require 'globalize'

class CreateTranslationTables < ActiveRecord::Migration[5.0]
  def self.up
    # Add translation tables
    Question.unscope(:where).create_translation_table!({ body: :text, explanation: :text }, { migrate_data: true })
    Answer.create_translation_table!({ body: :text }, { migrate_data: true } )
  end
  def self.down
    # Remove translation tables and add data
    Question.drop_translation_table! migrate_data: true
    Answer.drop_translation_table!   migrate_data: true
  end
end
