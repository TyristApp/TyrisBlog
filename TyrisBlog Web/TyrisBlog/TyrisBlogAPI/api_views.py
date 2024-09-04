import os
from django.http import JsonResponse
from rest_framework.decorators import api_view
from rest_framework import status
from rest_framework.response import Response
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, login, update_session_auth_hash
from rest_framework_simplejwt.tokens import RefreshToken, AccessToken
from rest_framework_simplejwt.exceptions import TokenError
from TyrisBlog import settings
from TyrisBlogAPI.models import AppInfo, Blog, BlogComment, BlogLike
from TyrisBlogAPI.serializers import BlogCommentSerializer, BlogSerializer
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser
from rest_framework.pagination import PageNumberPagination
from django.utils import timezone
from django.db.models import Count

@api_view(['POST'])
def create_user(request):
    email = request.query_params.get('email')
    password = request.query_params.get('password')
    firstname = request.query_params.get('first_name')
    lastname = request.query_params.get('last_name')
    username = request.query_params.get('username')

    if not email or not password or not firstname or not lastname or not username:
        return Response({'error': 'Eksik Veri'}, status=status.HTTP_401_UNAUTHORIZED)
        
    try:
        user = User.objects.create_user(
            username=username,
            email=email,
            password=password,
            first_name=firstname,
            last_name=lastname,
        )
 
         # Kullanıcı bilgilerini alma
        user_data = {
            'user_id': user.id,
            'username': user.username,
            'email': user.email,
            'first_name': user.first_name,
            'last_name': user.last_name
        }

        refresh = RefreshToken.for_user(user)
        access_token = str(refresh.access_token)
        refresh_token = str(refresh)

        login(request, user)

        return Response({'message': 'Kullanici olusturuldu',
            'access': access_token,
            'refresh': refresh_token,
            'user': user_data}, status=status.HTTP_201_CREATED)
    
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
def login_user(request):
    email = request.data.get('email') 
    password = request.data.get('password')

    if not email or not password:
        return Response({'error': 'Eksik Veri'}, status=status.HTTP_400_BAD_REQUEST)

  
    user = authenticate(username=email, password=password)

    if user is not None:
        login(request, user)

     
        refresh = RefreshToken.for_user(user)
        access_token = str(refresh.access_token)
        refresh_token = str(refresh)

        
        user_data = {
            'user_id': user.id,
            'username': user.username,
            'email': user.email,
            'first_name': user.first_name,
            'last_name': user.last_name
        }

        return Response({
            'message': 'Giriş Başarılı',
            'access': access_token,
            'refresh': refresh_token,
            'user': user_data
        }, status=status.HTTP_200_OK)
    else:
        return Response({'error': 'Geçersiz kullanıcı adı veya şifre'}, status=status.HTTP_401_UNAUTHORIZED)
    
@api_view(['POST'])
def check_token(request):
    
    auth_header = request.headers.get('Authorization')
    user = request.data.get('user')
    
    if not auth_header:
        return Response({'error': 'Authorization header missing'}, status=status.HTTP_400_BAD_REQUEST)
    
    token = auth_header.split(' ')[1]  

    try:
        AccessToken(token)  
        user_id = user['user_id']  
        user = User.objects.get(id=user_id) 
        login(request, user)
        return Response({'message': 'Token geçerli'}, status=status.HTTP_200_OK)
    except TokenError:
        return Response({'error': 'Geçersiz token'}, status=status.HTTP_401_UNAUTHORIZED)

@api_view(['POST'])
def create_blog(request):
    if not request.user.is_authenticated:
        return Response({'error': 'Giriş yapmanız gerekiyor'}, status=status.HTTP_401_UNAUTHORIZED)

    
    blog_image = request.FILES.get('blog_image')
    data = request.data.copy()
    data['user'] = request.user.id  

    serializer = BlogSerializer(data=data)
    if serializer.is_valid():
       
        blog_instance = serializer.save()
        if blog_image:
            blog_instance.blog_image = blog_image
            blog_instance.save()
        
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# Sayfalama sınıfı tanımı
class BlogPagination(PageNumberPagination):
    page_size = 20  
    page_size_query_param = 'page_size'
    max_page_size = 25 

@api_view(['GET'])
def list_blogs(request):
    blogs = Blog.objects.all().order_by('-blog_date') 
    paginator = BlogPagination()  
    result_page = paginator.paginate_queryset(blogs, request)  
    serializer = BlogSerializer(result_page, many=True)
    return paginator.get_paginated_response(serializer.data)  

@api_view(['GET'])
def list_blogs_by_user(request):
    user_id = request.GET.get('user_id') 

    if user_id is None:
        return Response({'error': 'user_id parametresi eksik'}, status=status.HTTP_400_BAD_REQUEST)

    try:
        blogs = Blog.objects.filter(user_id=user_id).order_by('-blog_date') 
    except Blog.DoesNotExist:
        return Response({'error': 'Bloglar bulunamadı'}, status=status.HTTP_404_NOT_FOUND)

    serializer = BlogSerializer(blogs, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)

@api_view(['GET'])
def blogs_by_title(request):
    title = request.GET.get('title', '')
    paginator = BlogPagination()  
    blogs = Blog.objects.filter(blog_title__icontains=title).order_by('-blog_date') 

    result_page = paginator.paginate_queryset(blogs, request)  
    serializer = BlogSerializer(result_page, many=True)
    
    return paginator.get_paginated_response(serializer.data) 

@api_view(['POST'])
def comment_on_blog(request):
    if not request.user.is_authenticated:
        return Response({'error': 'Giriş yapmanız gerekiyor'}, status=status.HTTP_401_UNAUTHORIZED)

    blog_id = request.data.get('blog_id')
    comment_content = request.data.get('comment_content')

    if not blog_id or not comment_content:
        return Response({'error': 'Blog ID and comment content are required.'}, status=status.HTTP_400_BAD_REQUEST)

    try:
        blog = Blog.objects.get(blog_id=blog_id)
    except Blog.DoesNotExist:
        return Response({'error': 'Blog not found.'}, status=status.HTTP_404_NOT_FOUND)

    comment = BlogComment.objects.create(
        blog=blog,
        user=request.user,
        comment_content=comment_content
    )

    serializer = BlogCommentSerializer(comment)
    return Response(serializer.data, status=status.HTTP_201_CREATED)

@api_view(['GET'])
def get_comments_by_blog(request):
    blog_id = request.GET.get('blog_id')

    if not blog_id:
        return Response({'error': 'Blog ID is required.'}, status=status.HTTP_400_BAD_REQUEST)

    try:
        blog = Blog.objects.get(blog_id=blog_id)
    except Blog.DoesNotExist:
        return Response({'error': 'Blog not found.'}, status=status.HTTP_404_NOT_FOUND)

    comments = BlogComment.objects.filter(blog=blog).order_by('-comment_time')  
    serializer = BlogCommentSerializer(comments, many=True)

    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['POST'])
def like_blog(request):
    if not request.user.is_authenticated:
        return Response({'error': 'Giriş yapmanız gerekiyor'}, status=status.HTTP_401_UNAUTHORIZED)

    data = request.data.copy()
    blog_id = data.get('blog_id')

    if not blog_id:
        return Response({'error': 'Blog ID gereklidir'}, status=status.HTTP_400_BAD_REQUEST)

    try:
        blog = Blog.objects.get(blog_id=blog_id)
    except Blog.DoesNotExist:
        return Response({'error': 'Blog bulunamadı'}, status=status.HTTP_404_NOT_FOUND)

    user = request.user
    existing_like = BlogLike.objects.filter(user=user, blog=blog).first()

    if existing_like:
        return Response({'error': 'Bu blogu zaten beğendiniz'}, status=status.HTTP_400_BAD_REQUEST)


    BlogLike.objects.create(user=user, blog=blog)
    return Response({'success': 'Blog başarıyla beğenildi'}, status=status.HTTP_201_CREATED)

@api_view(['GET'])
def blog_likes_status(request, blog_id):
    try:
      
        blog = Blog.objects.get(blog_id=blog_id)
        
       
        user = request.user
       
        total_likes = BlogLike.objects.filter(blog=blog).count()
        
    
        user_liked = BlogLike.objects.filter(blog=blog, user=user).exists()
        
  
        return Response({
            'total_likes': total_likes,
            'user_liked': user_liked
        }, status=status.HTTP_200_OK)

    except Blog.DoesNotExist:
        return Response({
            'error': 'Blog not found'
        }, status=status.HTTP_404_NOT_FOUND)
    
@api_view(['POST'])
def unlike_blog(request):
    if not request.user.is_authenticated:
        return Response({'error': 'Giriş yapmanız gerekiyor'}, status=status.HTTP_401_UNAUTHORIZED)

    data = request.data.copy()
    blog_id = data.get('blog_id')

    if not blog_id:
        return Response({'error': 'Blog ID gereklidir'}, status=status.HTTP_400_BAD_REQUEST)

    try:
        blog = Blog.objects.get(blog_id=blog_id)
    except Blog.DoesNotExist:
        return Response({'error': 'Blog bulunamadı'}, status=status.HTTP_404_NOT_FOUND)

    user = request.user
    existing_like = BlogLike.objects.filter(user=user, blog=blog).first().delete()


    return Response({'success': 'Blog like başarıyla silindi'}, status=status.HTTP_201_CREATED)

@api_view(['POST'])
def delete_blog(request):

    if not request.user.is_authenticated:
        return Response({'error': 'Giriş yapmanız gerekiyor'}, status=status.HTTP_401_UNAUTHOR)
    
    blog_id = request.data.get('blog_id')

    if not blog_id:
        return Response({'error': 'Blog ID gereklidir'}, status=status.HTTP_400_BAD_REQUEST)
    

    try:
        blog = Blog.objects.get(blog_id=int(blog_id))
    except Blog.DoesNotExist:
        return Response({'error': 'Blog bulunamadı'}, status=status.HTTP_404_NOT_FOUND)
    
    blog.delete()


    return Response({'success': 'Blog başarıyla silindi'}, status=status.HTTP_201_CREATED)


@api_view(['GET'])
def user_blog_comments(request, user_id):
    try:
      
        user = User.objects.get(id=user_id)

        comments = BlogComment.objects.filter(blog__in=Blog.objects.filter(user=user)).select_related('user', 'blog')
        
        
        comments_data = [
            {
                'comment_content': comment.comment_content,
                'commenter': comment.user.username,
                'blog_title': comment.blog.blog_title,
                'comment_time': comment.comment_time.strftime('%d.%m.%y %H:%M')  # Formatlama
            }
            for comment in comments
        ]
        
        
        return Response({
            'comments': comments_data
        }, status=status.HTTP_200_OK)

    except User.DoesNotExist:
        return Response({
            'error': 'User not found'
        }, status=status.HTTP_404_NOT_FOUND)


@api_view(['GET'])
def user_likes_status(request, user_id):
    try:
        
        user = User.objects.get(id=user_id)
        
        
        blogs = Blog.objects.filter(user=user)
        likes = BlogLike.objects.filter(blog__in=blogs).select_related('user', 'blog')
        
        likes_data = [
            {
                'blog_title': like.blog.blog_title,
                'liker': like.user.username,
            }
            for like in likes
        ]
        
 
        return Response({
            'likes': likes_data
        }, status=status.HTTP_200_OK)

    except User.DoesNotExist:
        return Response({
            'error': 'User not found'
        }, status=status.HTTP_404_NOT_FOUND)
    

@api_view(['POST'])
def update_email(request):
    user_id_str = request.data.get('user_id') 
    new_email = request.data.get('new_email')

    if not user_id_str or not new_email:
        return Response({'error': 'Eksik Veri'}, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        user_id = int(user_id_str)  
        user = User.objects.get(id=user_id)
        if User.objects.filter(email=new_email).exists():
            return Response({'error': 'Bu e-posta zaten kullanılıyor.'}, status=status.HTTP_400_BAD_REQUEST)
        
        user.email = new_email
        user.save()
        
        return Response({'message': 'E-posta başarıyla güncellendi.'}, status=status.HTTP_200_OK)
    except User.DoesNotExist:
        return Response({'error': 'Kullanıcı bulunamadı.'}, status=status.HTTP_404_NOT_FOUND)
    except ValueError:
        return Response({'error': 'Geçersiz kullanıcı ID'}, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({'error': f'Bir hata oluştu: {str(e)}'}, status=status.HTTP_400_BAD_REQUEST)
    

@api_view(['POST'])
def update_password(request):
    user_id = request.data.get('user_id')
    old_password = request.data.get('old_password')
    new_password = request.data.get('new_password')

    if not user_id or not old_password or not new_password:
        return Response({'error': 'Eksik Veri'}, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        user = User.objects.get(id=user_id)
        if not user.check_password(old_password):
            return Response({'error': 'Eski şifre yanlış'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Şifreyi güncelle
        user.set_password(new_password)
        user.save()
        
       
        update_session_auth_hash(request, user)
        
        return Response({'message': 'Şifre başarıyla güncellendi.'}, status=status.HTTP_200_OK)
    except User.DoesNotExist:
        return Response({'error': 'Kullanıcı bulunamadı.'}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({'error': f'Bir hata oluştu: {str(e)}'}, status=status.HTTP_400_BAD_REQUEST)

@api_view(['DELETE'])
def delete_user(request):
    user_id = request.query_params.get('user_id')
    
    if not user_id:
        return Response({'error': 'Eksik veri: user_id gerekli'}, status=status.HTTP_400_BAD_REQUEST)

    try:
        user = User.objects.get(id=user_id)
        user.delete()
        return Response({'message': 'Kullanıcı başarıyla silindi'}, status=status.HTTP_200_OK)
    except User.DoesNotExist:
        return Response({'error': 'Kullanıcı bulunamadı'}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
    
@api_view(['GET'])
def get_app_info(request):
    try:
       
        app_info_records = AppInfo.objects.all()
        
        if not app_info_records:
            return Response({'error': 'AppInfo kayıtları bulunamadı.'}, status=status.HTTP_404_NOT_FOUND)
        
        data = {record.info_name: record.value for record in app_info_records}
        
        return Response(data, status=status.HTTP_200_OK)
    
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    

@api_view(['POST'])
def upload_image(request):
    parser_classes = [MultiPartParser]
    
    if 'image' not in request.FILES:
        return JsonResponse({'error': 'No image file uploaded'}, status=status.HTTP_400_BAD_REQUEST)

    image = request.FILES['image']
    file_name = image.name
    file_path = os.path.join(settings.MEDIA_ROOT, 'uploaded_images', file_name)
    

    os.makedirs(os.path.dirname(file_path), exist_ok=True)

    with open(file_path, 'wb+') as destination:
        for chunk in image.chunks():
            destination.write(chunk)

   
    relative_file_url = os.path.join('media', 'uploaded_images', file_name)

    return JsonResponse({'message': 'Image uploaded successfully', 'file_url': relative_file_url}, status=status.HTTP_201_CREATED)

@api_view(['GET'])
def favorite_blogs_of_month(request):

    start_date = timezone.now().replace(day=1)
    end_date = timezone.now().replace(month=timezone.now().month + 1, day=1) - timezone.timedelta(days=1)
    
    blogs = Blog.objects.filter(blog_date__range=(start_date, end_date)) \
                         .annotate(like_count=Count('bloglike')) \
                         .order_by('-like_count')[:20]
    
    serializer = BlogSerializer(blogs, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)