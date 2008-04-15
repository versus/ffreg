class HistoriesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @history_pages, @histories = paginate :histories, :per_page => 10
  end

  def show
    @history = History.find(params[:id])
  end

  def new
    @history = History.new
  end

  def create
    @history = History.new(params[:history])
    if @history.save
      flash[:notice] = 'History was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @history = History.find(params[:id])
  end

  def update
    @history = History.find(params[:id])
    if @history.update_attributes(params[:history])
      flash[:notice] = 'History was successfully updated.'
      redirect_to :action => 'show', :id => @history
    else
      render :action => 'edit'
    end
  end

  def destroy
    History.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
