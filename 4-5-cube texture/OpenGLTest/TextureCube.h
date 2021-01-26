//
//  TetureCube.h
//  OpenGLTest
//
//  Created by Zero on 2021/1/26.
//  Copyright © 2021 Lenz. All rights reserved.
//

#ifndef TetureCube_h
#define TetureCube_h
#include "Texture.h"
#include <vector>

class TextureCube {
    
private:
    unsigned int textureId;
public:
    
    //环绕方式 x,y,z -> s,t,r
    //GL_REPEAT,GL_MIRRORED_REPEAT,GL_CLAMP_TO_EDGE,GL_CLAMP_TO_BORDER
    void setWrap2D(int wrap) {
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,wrap);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,wrap);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_R,wrap);
    }
    
    //GL_NEAREST（默认，当小纹理图片放到大物体上时会有颗粒感） GL_LINEAR（计算临近插值，小纹理图片放到大物体上时会平滑过度） 两种过滤方式；
    void setFilter(int filter) {
        //GL_NEAREST
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, filter); //缩小时
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); //放大时
    }
    
    unsigned int begin(int unit = GL_TEXTURE0) {
       unsigned int texture;
       glGenTextures(1,&texture);
       glBindTexture(GL_TEXTURE_CUBE_MAP,texture);
        textureId = texture;
        return texture;
    }
    
    void end(std::vector<std::string> textures_faces) {
        int width,height,nrChannels;
        unsigned char *data;
        for (unsigned int i = 0; i < textures_faces.size(); i++) {
            data = stbi_load(textures_faces[i].c_str(), &width, &height, &nrChannels, 0);
            if (data) {
                glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i,0,GL_RGB,width,height,0,GL_RGB,GL_UNSIGNED_BYTE,data);
                stbi_image_free(data);

            } else {
                std::cout << "Cubemap texture failed to load at path: " << textures_faces[i] << std::endl;
                stbi_image_free(data);
            }
        }
    }
    
    void use() {
        glBindTexture(GL_TEXTURE_CUBE_MAP,textureId);
    }
};

#endif /* TetureCube_h */
