class PagesController < ApplicationController
  def index
    @rinks = Patinoire.geocoded
    @count = Patinoire.geocoded.ouvert.count
    @last_updated = Arrondissement.maximum(:date_maj)
    fresh_when etag: @rinks, last_modified: @rinks.maximum(:updated_at).utc, public: true
  end

  def data
    respond_to do |format|
      format.xml do
        render xml: Patinoire.all.to_xml({
          skip_types: true,
          dasherize: false,
          only: [:id, :slug, :nom, :genre, :description, :parc, :ouvert, :deblaye, :arrose, :resurface, :condition, :adresse, :tel, :ext, :lat, :lng],
          include: {
            arrondissement: {
              only: [:nom_arr, :cle, :date_maj],
            },
          },
        })
      end
      format.json do
        render json: Arrondissement.all.to_json({
          only: [:nom_arr, :cle, :date_maj],
          include: {
            patinoires: {
              only: [:id, :slug, :nom, :genre, :description, :parc, :ouvert, :deblaye, :arrose, :resurface, :condition, :adresse, :tel, :ext, :lat, :lng],
            },
          },
        })
      end
    end
  end

  def channel
    render layout: false
  end
end
