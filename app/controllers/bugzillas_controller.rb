class BugzillasController < ApplicationController

  layout "index"

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @bugzilla_pages, @bugzillas = paginate :bugzillas, :per_page => 10
  end

  def show
    @bugzilla = Bugzilla.find(params[:id])
  end

  def new
    @bugzilla = Bugzilla.new
  end

  def create
    @bugzilla = Bugzilla.new(params[:bugzilla])
    @bugzilla.create_at =Time.now
    if @bugzilla.save
      flash[:notice] = 'Спасибо! Мы рассмотрим ваш отзыв в самое кратчайшее время'
      redirect_to :action => 'index',:controller => :welcome, :id => @bugzilla
    else
      render :action => 'new'
    end
  end

  def edit
    @bugzilla = Bugzilla.find(params[:id])
  end

  def update
    @bugzilla = Bugzilla.find(params[:id])
    if @bugzilla.update_attributes(params[:bugzilla])
      flash[:notice] = 'Bugzilla was successfully updated.'
      redirect_to :action => 'index',:controller => :welcome, :id => @bugzilla
    else
      render :action => 'edit'
    end
  end

  def destroy
    Bugzilla.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
