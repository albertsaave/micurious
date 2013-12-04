class QuestionsController < ApplicationController
  before_action :load_answers_and_updates, only: [:show]
  before_action :load_categories, only: [:filter, :show]

  def show
      @question = Question.where("id = ? AND status != 'Removed'", params[:id]).first
    @question = Question.find(params[:id])
    redirect_to root_url if @question.status == Question::Status::Removed
  end

  def filter

    if params[:status] == 'archive'
      @unanswered_class = "highlighted"
      statuses = [Question::Status::New]
    elsif params[:status] == 'answered'
      @answered_class = "highlighted"
      statuses = [Question::Status::Answered, Question::Status::Investigating]
    end

    @questions = Question.with_status_and_category(statuses, params[:category_name]).paginate(page: params[:page])
    @featured_answers =  Question.with_status_and_category(statuses, params[:category_name]).where(featured: true)
    render 'index'
  end

  def new
    @question = Question.new
    @categories = Category.all
    @question.attributes = params.permit(:display_text, :description, :name, :anonymous,
                                         :email, :email_confirmation, :neighbourhood,
                                         :picture_url, :picture_owner, :picture_attribution_url, :category_ids => [])
    respond_to do |format|
      format.js
    end
  end

  def create
    @question = Question.new(question_params)

    respond_to do |format|
      if @question.save
        format.js { render "received.js.erb" }
      else
        @categories = Category.all
        format.js { render "new.js.erb" }
      end
    end
  end

  def picture
    @question = Question.new(question_params)
    @categories = Category.all
    respond_to do |format|
      format.js { render @question.valid? ? 'picture.js.erb' : 'new.js.erb' }
    end
  end

  def find_pictures
    @pictures = FlickrService.new.find_pictures params["Search"]
    respond_to do |format|
      format.js { render 'find_pictures.js.erb' }
    end
  end

  def confirm
    @question = Question.new(question_params)
    @categories = Category.all
    respond_to do |format|
      format.js { render @question.valid? ? 'confirm.js.erb' : 'new.js.erb' }
    end
  end

  private
    def question_params
      params.require(:question).permit(:searchfield, :original_text, :display_text, :description, :name, :anonymous, :email, :email_confirmation, :neighbourhood, :picture_url, :picture_owner, :picture_attribution_url, :category_ids => [] )
    end

    def load_answers_and_updates
      ordered_answers_both_types = Question.find(params[:id]).answers.order(:position)
      @answers = ordered_answers_both_types.where(type: Answer::Type::Answer)
      @updates = ordered_answers_both_types.where(type: Answer::Type::Update)
    end
end
