class RevisionsController < ApplicationController

  def show
    @revision = Revision.find(params[:id])
    @revision_parser = RevisionParser.new(@revision)
  end
end
