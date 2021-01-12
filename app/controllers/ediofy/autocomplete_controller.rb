class Ediofy::AutocompleteController < EdiofyController
  def tags
    if params[:q]
      like= "%#{params[:q]}%"
      tags = Tag.where("name ILIKE ?", like)
    else
      tags = []
    end
    list = tags.map {|t| Hash[ id: t.id, label: t.name, name: t.name]}
    render json: list.as_json
  end

  def universities
    if params[:q]
      like= "%#{params[:q]}%"
      universities = University.where("name ILIKE ? OR abbreviation ILIKE ?", like, like)
    else
      universities = []
    end
    list = universities.map {|t| Hash[ id: t.id, label: t.name, name: t.name]}
    render json: list.as_json
  end

  def persons_and_companies
    if params[:q] && params[:q].length > 0
      like= "%#{params[:q]}%"
      results = User.where("full_name ILIKE ? AND ghost_mode =? AND private =? AND is_active=?", like, false, false, true).select(:id, :avatar, :full_name, :title, :ghost_mode, :specialty_id)
    else
      results = []
    end

    list = results.map {|r| Hash[ id:r.id, photo: (r.ghost_mode ? r.avatar.default_url : r.avatar.small.url), name: r.full_name,
                                  specialty_name: r.specialty_name]}
    render json: list.as_json
  end
end