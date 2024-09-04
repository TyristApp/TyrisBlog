from django.db import models
from django.contrib.auth.models import User
from django.utils.text import slugify

class Blog(models.Model):
    blog_id = models.AutoField(primary_key=True)
    blog_content = models.TextField()
    blog_title = models.CharField(max_length=255)
    blog_date = models.DateTimeField(auto_now_add=True)
    blog_slug = models.SlugField(unique=True)
    is_active = models.BooleanField(default=True)
    blog_image = models.ImageField(upload_to='blog-images-cover/', null=True, blank=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='blogs')

    def save(self, *args, **kwargs):
        if not self.blog_slug:
            self.blog_slug = slugify(self.blog_title)
        super(Blog, self).save(*args, **kwargs)

    def __str__(self):
        return self.blog_title
    
    class Meta:
        db_table = 'Blog'

class BlogView(models.Model):
    blog = models.ForeignKey(Blog, on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.CASCADE)

    class Meta:
        unique_together = ('blog', 'user')

    class Meta:
        db_table = 'Blog_Views'

class BlogLike(models.Model):
    blog = models.ForeignKey(Blog, on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.CASCADE)

    class Meta:
        unique_together = ('blog', 'user')

    class Meta:
        db_table = 'Blog_Likes'

class Tag(models.Model):
    tag_id = models.AutoField(primary_key=True)
    tag_name = models.CharField(max_length=50)

    def __str__(self):
        return self.tag_name
    
    class Meta:
        db_table = 'Tag'

class BlogTag(models.Model):
    blog = models.ForeignKey(Blog, on_delete=models.CASCADE)
    tag = models.ForeignKey(Tag, on_delete=models.CASCADE)

    class Meta:
        unique_together = ('blog', 'tag')

    class Meta:
        db_table = 'Blog_Tags'

class BlogComment(models.Model):
    comment_id = models.AutoField(primary_key=True)
    comment_content = models.TextField()
    comment_time = models.DateTimeField(auto_now_add=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    blog = models.ForeignKey(Blog, on_delete=models.CASCADE)

    def __str__(self):
        return f"Comment by {self.user.username} on {self.blog.blog_title}"
    
    class Meta:
        db_table = 'Blog_Comments'

class AppInfo(models.Model):
    info_name = models.CharField(max_length=255)
    value = models.BooleanField(default=False)

    class Meta:
        db_table = 'App_Info'