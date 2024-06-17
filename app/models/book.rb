class Book < ApplicationRecord
    validates_presence_of :title, :author_id, :author_full_name

    def self.paginate_data(params)
        books = self

        if params[:filter_by_title].present?
            books = books.where("title LIKE :query", query: "%#{params[:filter_by_title]}%") 
        end
        if params[:filter_by_author].present?
            books = books.where("author_full_name LIKE :query", query: "%#{params[:filter_by_author]}%") 
        end
        
        count = books.count
        books = books.order("#{params[:sort_by] || :id} #{params[:sort_type] || :DESC}")
        books = books.page(params[:page] || 1).per_page(params[:per_page] || 20) unless ActiveModel::Type::Boolean.new.cast(params[:all]).present?
        books 
    end

end