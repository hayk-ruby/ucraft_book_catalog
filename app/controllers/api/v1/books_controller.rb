class Api::V1::BooksController < ApplicationController
    before_action :authorize_request
    before_action :set_book, only: [:show, :update, :destroy]
    before_action :check_author, only: [:create, :update]
    before_action :set_books, only: [:index]
    before_action :set_author_books, only: [:update_auther_books, :delete_auther_books]
    before_action :get_authors_list, only: [:get_authors]


    def index
        render json: @books
    end
  
    def get_authors
        render json: @authors
    end

    def create
        book = Book.new(book_params.merge author_full_name: @author_full_name)
        return render json: {errors: book.errors.full_messages}, status: :bad_request unless book.save
        render json: book
    end
  
    def show
        render json: @book
    end

    def update
        unless @book.update(book_params.merge author_full_name: @author_full_name)
            return render json: {errors: @book.errors.full_messages}, status: :bad_request
        end
        render json: @book
    end
  
    def destroy
        return render json: {errors: 'not deleted'}, status: :bad_request unless @book.destroy
        render json: {message: 'deleted'}, status: :accepted
    end
  
    def update_auther_books
        @author_books.update_all(author_full_name: params[:author_full_name])
    end

    def delete_auther_books
        @author_books.destroy_all
    end


    private
  
    def set_author_books
        return render json: {errors: 'Invalid token'}, status: :not_found if params[:token] != 'e9V3tB6vBpPavjRY6u1bdG'
        @author_books = Book.where(author_id: params[:author_id])
    end

    def set_books
        @books = Book.paginate_data(params)
    end
    
    def book_params
        params.permit(:title, :description, :author_id)
    end
  
    def set_book
        @book = Book.find_by_id(params[:id])
        return render json: {errors: 'Not found'}, status: :not_found if @book.nil?
    end
    
    def check_author
        if @book.blank? || (book_params[:author_id].present? || @book.author_id !=  book_params[:author_id])
            bearer = request.headers[:Authorization]
            author_id = book_params[:author_id] || @book.author_id
            
            begin
                uri = URI.parse("http://127.0.0.1:3001/api/v1/authors/#{author_id}")
                request = Net::HTTP::Get.new(uri)
                request.content_type = "application/json"
                
                request['Authorization'] = bearer
                req_options = {
                use_ssl: uri.scheme == "https",
                }
                response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
                    http.request(request)
                end
                
                @author_full_name = JSON.parse(response.body)["full_name"]
                if @author_full_name.nil?
                    return render json:  {errors: 'author not found'}, status: :bad_request
                end
            rescue
                return render json:  {errors: 'author not found'}, status: :bad_request
            end

        end
    end


    def get_authors_list
        bearer = request.headers[:Authorization]

        begin
            uri = URI.parse("http://127.0.0.1:3001/api/v1/authors")
            request = Net::HTTP::Get.new(uri)
            request.content_type = "application/json"
            
            request['Authorization'] = bearer
            req_options = {
            use_ssl: uri.scheme == "https",
            }
            response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
                http.request(request)
            end
            
            @authors = response.body
        rescue
            return render json:  {errors: 'Something went wrong'}, status: :bad_request
        end

    end

  end