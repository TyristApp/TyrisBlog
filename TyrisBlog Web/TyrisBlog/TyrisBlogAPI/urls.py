from django.urls import path
from TyrisBlogAPI.api_views import create_user, login_user, check_token, create_blog,list_blogs,list_blogs_by_user, blogs_by_title, comment_on_blog,get_comments_by_blog, like_blog,blog_likes_status,unlike_blog,delete_blog,user_likes_status,user_blog_comments,update_email, update_password,delete_user,get_app_info,upload_image,favorite_blogs_of_month

urlpatterns = [
    path('user/create/', create_user, name='user-create'),
    path('user/login/', login_user, name='user-login'),
    path('user/check-token/', check_token, name='check-token'),
    path('blog/create/', create_blog, name='create-blog'),
    path('blogs/', list_blogs, name='list-blogs'),
    path('blogs-by-user/', list_blogs_by_user, name='list-blogs-by-user'),
    path('blogs-by-title/', blogs_by_title, name='list-blogs-by-title'),
    path('comment-blog/', comment_on_blog, name='comment-blog'),
    path('get-comments-by-blog/', get_comments_by_blog, name='get-comment-by-blog'),
    path('like-blog/', like_blog, name='like-blog'),
    path('blog-likes-status/<int:blog_id>/', blog_likes_status, name='blog-likes-status'),
    path('unlike-blog/', unlike_blog, name='blog-unlike'),
    path('delete-blog/', delete_blog, name='delete-blog'),
    path('user-likes-status/<int:user_id>/', user_likes_status, name='user-likes-status'),
    path('user-comment-status/<int:user_id>/', user_blog_comments, name='user-likes-status'),
    path('update-email/', update_email, name='email-update'),
    path('update_password/', update_password, name='password-update'),
    path('delete-user/', delete_user, name='delete-user'),
    path('get-app-info/', get_app_info, name='get-app-info'),
    path('upload-image/', upload_image, name='upload-image'),
    path('favorite-blogs-of-month/', favorite_blogs_of_month, name='favorite_blogs_of_month'),
]
