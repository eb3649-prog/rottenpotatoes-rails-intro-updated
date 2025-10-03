class MoviesController < ApplicationController
  # enable :sessions

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    @ratings_to_show = []

    if params[:ratings].nil? && params[:sort_by].nil? 
      flash.keep
      redirect_to movies_path(
        sort_by: session[:sort_by],
        ratings: Hash[session[:ratings].map{ |r| [r,1] }]
      ) and return 
    end

    #save the action for the very end
    if params[:ratings]
      @ratings_to_show = params[:ratings].keys
      session[:ratings] = @ratings_to_show
    else 
      if params[:commit]
        @ratings_to_show = @all_ratings
        session[:ratings] = @ratings_to_show
      elsif session[:ratings]
        @ratings_to_show = session[:ratings]
      else
        #if no checkboxes, then show everything
        @ratings_to_show = @all_ratings
        session[:ratings] = @ratings_to_show
      end
    end 

    

    if params[:sort_by]
      @sort = params[:sort_by]
      session[:sort_by] = @sort
    else 
      @sort = session[:sort_by]
    end

    @movies = Movie.where(rating: @ratings_to_show)
    @movies = @movies.order(@sort)
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
