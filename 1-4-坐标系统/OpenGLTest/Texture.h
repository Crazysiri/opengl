//
//  Texture.h
//  OpenGLTest
//
//  Created by Zero on 2020/12/3.
//  Copyright © 2020 Lenz. All rights reserved.
//

#ifndef Texture_h
#define Texture_h

#include <glad/glad.h>
#include <string>
#include <fstream>
#include <sstream>
#include <iostream>

//通过定义STB_IMAGE_IMPLEMENTATION，预处理器会修改头文件，让其只包含相关的函数定义源码，等于是将这个头文件变为一个 .cpp 文件了
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

class Texture {
public:
    //环绕方式 x,y,z -> s,t,r
    //GL_REPEAT,GL_MIRRORED_REPEAT,GL_CLAMP_TO_EDGE,GL_CLAMP_TO_BORDER
    void setWrap2D(int wrap) {
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,wrap);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,wrap);
    }
    
    void setBorderColor(float color[4]) {
        glTexParameterfv(GL_TEXTURE_2D,GL_TEXTURE_BORDER_COLOR,color);
    }
    
    //GL_NEAREST（默认，当小纹理图片放到大物体上时会有颗粒感） GL_LINEAR（计算临近插值，小纹理图片放到大物体上时会平滑过度） 两种过滤方式；
    void setFilter(int filter) {
        //GL_NEAREST
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, filter); //缩小时
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); //放大时
    }
    
    //多级渐远纹理 近的物体分辨率高 远的物体分辨率低
    //glGenerateMipmaps：GL_NEAREST_MIPMAP_NEAREST GL_LINEAR_MIPMAP_NEAREST GL_NEAREST_MIPMAP_LINEAR GL_LINEAR_MIPMAP_LINEAR
    void setMipMap(int type) {
        //GL_NEAREST_MIPMAP_LINEAR
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, type);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); //注：为放大过滤设置多级渐远纹理 会收到错误代码，因为没有任何效果
    }

    /*
     必须在begin 和 end之间调用 上面几个方法
     */
    
    unsigned int begin(int unit = GL_TEXTURE0) {
       unsigned int texture;
       glGenTextures(1,&texture);
        //一个纹理的位置值 通常称为一个纹理单元 texture unit
        glActiveTexture(unit); //在绑定纹理前先激活纹理单元，opengl 保证至少16个纹理单元 GL_TEXTURE0 - GL_TEXTURE15
       glBindTexture(GL_TEXTURE_2D,texture);
        
        return texture;
//        unsigned int texture1;
//        glGenTextures(1,&texture1);
//         //一个纹理的位置值 通常称为一个纹理单元 texture unit
//         glActiveTexture(GL_TEXTURE1); //在绑定纹理前先激活纹理单元，opengl 保证至少16个纹理单元 GL_TEXTURE0 - GL_TEXTURE15
//        glBindTexture(GL_TEXTURE_2D,texture1);
    }
    
    void end(const char *file) {
        int width,height,nrChannels;
        stbi_set_flip_vertically_on_load(true); // tell stb_image.h to flip loaded texture's on the y-axis.
         unsigned char *data = stbi_load(file, &width, &height, &nrChannels, 0);
         
        /*1.GL_TEXTURE_3D
          2.多级渐远纹理级别，手动单独设置就填0 （setMipMap）
          3.纹理存为何种格式
          4&5.纹理的高度和宽度
          6.总是0 ，历史遗留
          7&8.源图的格式和数据类型
         */
        if (data) {
            glTexImage2D(GL_TEXTURE_2D,0,GL_RGB,width,height,0,GL_RGB,GL_UNSIGNED_BYTE,data);
            
            glGenerateMipmap(GL_TEXTURE_2D);
        } else {
            std::cout << "Failed to load texture" << std::endl;
        }
        
        stbi_image_free(data);
    }
    

};
#endif /* Texture_h */
