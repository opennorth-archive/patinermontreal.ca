class PagesController < ApplicationController
  def index
    @rinks = Patinoire.geocoded
    @fraction = @rinks.ouvert.count / @rinks.tracked.count.to_f
    @last_updated = Arrondissement.maximum(:date_maj)
    fresh_when etag: @rinks, last_modified: (@rinks.maximum(:updated_at) || Time.now).utc, public: true
  end

  def data
    arrondissement_fields = [:nom_arr, :cle, :date_maj]
    patinoires_fields = [:id, :slug, :nom, :genre, :description, :parc, :ouvert, :deblaye, :arrose, :resurface, :condition, :adresse, :tel, :ext, :lat, :lng]

    respond_to do |format|
      format.xml do
        render xml: Patinoire.all.to_xml({
          skip_types: true,
          dasherize: false,
          only: patinoires_fields,
          include: {
            arrondissement: {
              only: arrondissement_fields,
            },
          },
        })
      end
      format.json do
        render json: Arrondissement.all.as_json({
          only: arrondissement_fields,
          include: {
            patinoires: {
              only: patinoires_fields,
            },
          },
        })
      end
    end
  end

  def conditions
    arrondissement_fields = [:nom_arr, :date_maj]
    patinoires_fields = [:id, :ouvert, :deblaye, :arrose, :resurface, :condition]

    respond_to do |format|
      format.xml do
        render xml: Patinoire.all.to_xml({
          skip_types: true,
          dasherize: false,
          only: patinoires_fields,
          include: {
            arrondissement: {
              only: arrondissement_fields,
            },
          },
        })
      end
      format.json do
        render json: Arrondissement.dynamic.to_json({
          only: arrondissement_fields,
          include: {
            patinoires: {
              only: patinoires_fields,
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
