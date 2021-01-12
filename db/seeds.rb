seed_file = Rails.root.join('db', 'seed.yml')
objects = YAML::load_file(seed_file)

# Create a member login for development and staging
if Rails.env.development? || Rails.env.staging?
  [Address, User, AdminUser].each do |model|
    name = model.to_s.pluralize.underscore

    unless model.exists?
      puts "** Creating #{name}"
      attributes = objects[name].first
      puts "** #{model} created with login: '#{attributes['email']}' and password: '#{attributes['password']}'"
      model.create! attributes
      ActiveRecord::Base.connection.reset_pk_sequence!(model.table_name)
    else
      puts "** Skipping #{name}, already created"
    end
  end

  [Interest, Question].each do |model|
    name = model.to_s.pluralize.underscore

    if model.count < 1 then
      puts "** Creating #{name}"
      objects[name].each do |obj|
        obj['user'] = User.first if model == Question
        model.create! obj
      end
      ActiveRecord::Base.connection.reset_pk_sequence!(model.table_name)
    else
      puts "** Skipping #{name}, already created"
    end
  end
end

if University.count < 1
  objects['universities'].each do |obj|
    University.create! obj
  end
end

# Make sure all built-in badges are instantiated
Badge.descendants.each { |subclass| subclass.instance if subclass.respond_to? :instance }
