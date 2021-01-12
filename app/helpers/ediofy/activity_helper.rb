module Ediofy::ActivityHelper

  # Runs through an activities relation, attempts to builds paths for any relation
  # and creates a translation key based off the original translation key with _html
  # on the end (html_safe translations).  If the _html version of the key does not exist
  # it defaults to the submitted translation key.
  def activity_link(activity)
    count = activity.child_ids.count + 1

    variables = activity.variables
    relations = activity.relations

    options = variables.merge(relations).merge(activity_relation_paths(relations))
    options = options.merge(user: activity.user, scope: "activities", count: count )

    # Search for HTML_safe version of key before falling back to key
    t(activity.key+'_html', options.merge(default: t(activity.key,options))).to_s
  end

  protected

  # Given a hash of Activity.relations, loop through and attempt to create ediofy
  # public paths for each
  def activity_relation_paths(relations)
    relation_paths = {}

    # Rudimentarily attempt to build paths for all the relations
    relations.each do |key, rel|
      key = :"#{key}_path"

      begin
        relation_paths[key] = url_for([:ediofy, rel])
      rescue NoMethodError
        relation_paths[key] = ''
      end
    end

    relation_paths
  end

end