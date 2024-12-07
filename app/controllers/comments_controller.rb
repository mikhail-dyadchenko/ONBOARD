class CommentsController < ApplicationController
  before_action :set_post, only: %i[ create destroy ]

  def create
    @comment = @post.comments.create(params[:comment].permit(:body))
    redirect_to post_path(@post)
  end

  def destroy
    @comment = @post.comments.find(params[:id])
    @comment.destroy
    redirect_to post_path(@post)
  end

  private

    def set_post
      @post = Post.find(params[:post_id])
    end
end
