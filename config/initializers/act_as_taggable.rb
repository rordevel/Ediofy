ActsAsTaggableOn.default_parser = TagParser

module ActsAsTaggableOn
  class Tagging < ::ActiveRecord::Base
    # Execute callback functions on content and their groups
    belongs_to :taggable, polymorphic: true, touch: true
  end
end
