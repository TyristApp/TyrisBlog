from rest_framework import serializers
from .models import Blog, BlogLike, BlogComment, BlogTag, Tag, BlogView
from django.contrib.auth.models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['first_name', 'last_name', 'email','username','user_id']

class BlogSerializer(serializers.ModelSerializer):
    username = serializers.SerializerMethodField()
    class Meta:
        model = Blog
        fields = ['blog_id', 'blog_title', 'blog_content', 'blog_date', 'blog_slug', 'is_active', 'blog_image', 'username','user']
        read_only_fields = ['blog_date', 'blog_slug']
    
    def get_username(self, obj):
    
        return obj.user.username if obj.user else None

class BlogCommentSerializer(serializers.ModelSerializer):
    username = serializers.SerializerMethodField()
    class Meta:
        model = BlogComment
        fields = ['comment_id', 'comment_content', 'comment_time', 'user', 'blog', 'username']
    
        
    def get_username(self, obj):
      
        return obj.user.username if obj.user else None

class TagSerializer(serializers.ModelSerializer):
    class Meta:
        model = Tag
        fields = ['tag_id', 'tag_name']

class BlogTagSerializer(serializers.ModelSerializer):
    class Meta:
        model = BlogTag
        fields = ['blog', 'tag']

class BlogLikeSerializer(serializers.ModelSerializer):
    class Meta:
        model = BlogLike
        fields = ['blog', 'user']

class BlogViewSerializer(serializers.ModelSerializer):
    class Meta:
        model = BlogView
        fields = ['blog', 'user']

