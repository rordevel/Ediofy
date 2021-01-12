ActiveAdmin.register Badge do
  menu priority: 6
  # permit_params [:name, :points, :value]
  index do
    selectable_column
    id_column
    column :name
    column "Icon" do |b|
      image_tag b.image.stream.url, size: "32x32", alt: b
    end
    column :points
    column "Type" do |b|
      b.human_type
    end
    column :value
    column "Users" do |b|
      b.users.count || 0
    end
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :image_cache, as: :hidden
      f.input :image, as: :file#, hint: form_file_hint_helper(f.object.image)
      f.input :points, hint: "How many points does a member earn for winning this badge?"
      f.input :type, as: :radio, collection: createable_badge_classes, member_label: :human_type if not f.object.persisted?
      f.input :value, hint: "How many <things> does the member need to accrue to win this badge?" if not f.object.persisted? or f.object.class.in? createable_badge_classes
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row "Icon" do |b|
        image_tag b.image.stream.url, size: "32x32", alt: b
      end
      row :points
      row "Type" do |b|
        b.human_type
      end
      row :value
      panel "Users" do
        table do
          thead do
            th "Name"
            th "Points"
            th "Creation date"
            th "Date badge achieved"
          end
          tbody do
            badge.badge_users.includes(:user).each do |u|
              tr do
                td u.user.full_name
                td u.user.points.where("created_at <= ?", u.created_at).total
                td u.user.created_at
                td u.created_at
              end
            end
          end
        end
      end
    end
  end

  controller do
    def create
      if not (badge_class = createable_badge_classes.find { |badge_class| badge_class.name == params[:badge].try(:[], :type) })
        @badge = Badge.new params[:badge]
        @badge.errors.add :type, "is not valid"
      else
        @badge = badge_class.create(badge_params)
        if @badge.errors.blank?  
          redirect_to admin_badges_path, flash: { notice: "#{params[:badge][:type]} has been created successfully" }
        else
          render :new
        end
      end
    end

    protected
    def badge_params
      params.require(:badge).permit [:name, :points, :value, :image, :image_cache]
    end
    # We have to manage createable badge classes here -- not in the Badge class --
    # to avoid autoload loops.
    def createable_badge_classes
      [PointsBadge, LevelBadge, QuestionsAnsweredBadge, QuestionsSubmittedBadge, QuestionsVotedBadge]
    end

    helper_method :createable_badge_classes
  end
end