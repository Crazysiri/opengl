//
//  Mesh.h
//  OpenGLTest
//
//  Created by Zero on 2021/1/8.
//  Copyright © 2021 Lenz. All rights reserved.
//

#ifndef Mesh_h
#define Mesh_h

#include <string>
#include <fstream>
#include <sstream>
#include <iostream>
#include <vector>

#include <glad/glad.h>

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>
#include "Shader.h"

#include <assimp/types.h>

namespace assimp {
    struct Vertex {
        glm::vec3 Position;
        glm::vec3 Normal;
        glm::vec2 TexCoords;
        glm::vec3 Tangent;
        glm::vec3 Bitangent;
    };

    struct Texture {
        unsigned int id;
        std::string type;
        aiString path;
    };

    class Mesh {
    public:
        std::vector<Vertex> vertices;
        std::vector<unsigned int> indices;
        std::vector<Texture> textures;
        
        Mesh(std::vector<Vertex> vertices,std::vector<unsigned int> indices,std::vector<Texture> textures) {
            this->vertices = vertices;
            this->indices = indices;
            this->textures = textures;
            
            setupMesh();
        }
        
        void Draw(Shader &shader) {
            unsigned int diffuseNr = 1;
            unsigned int specularNr = 1;
            unsigned int normalNr = 1;
            unsigned int heightNr = 1;
            
            for (unsigned int i = 0; i < textures.size(); i++) {
                glActiveTexture(GL_TEXTURE0 + i);
                std::string number;
                std::string name = textures[i].type;
                if (name == "texture_diffuse") {
                    number = std::to_string(diffuseNr++);
                } else if (name == "texture_specular") {
                    number = std::to_string(specularNr++);
                } else if (name == "texture_normal") {
                    number = std::to_string(normalNr++);
                } else if (name == "texture_height") {
                    number = std::to_string(heightNr++);
                }
                
                shader.setInt(name + number, i);
                glBindTexture(GL_TEXTURE_2D,textures[i].id);
                
            }
            
            glBindVertexArray(VAO);
            glDrawElements(GL_TRIANGLES,indices.size(),GL_UNSIGNED_INT,0);
            glBindVertexArray(0);
            
            // always good practice to set everything back to defaults once configured.
            glActiveTexture(GL_TEXTURE0);
        }
        
    private:
        unsigned int VAO,VBO,EBO;
        
        void setupMesh() {
            glGenVertexArrays(1,&VAO);
            glGenBuffers(1,&VBO);
            glGenBuffers(1,&EBO);
            
            glBindVertexArray(VAO);
            glBindBuffer(GL_ARRAY_BUFFER,VBO);
            glBufferData(GL_ARRAY_BUFFER,vertices.size() * sizeof(Vertex),&vertices[0],GL_STATIC_DRAW);
            
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,EBO);
            glBufferData(GL_ELEMENT_ARRAY_BUFFER,indices.size() * sizeof(unsigned int),&indices[0],GL_STATIC_DRAW);
            
            
            glEnableVertexAttribArray(0);
            glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,sizeof(Vertex),(void *)0);
            
            glEnableVertexAttribArray(1);
            glVertexAttribPointer(1,3,GL_FLOAT,GL_FALSE,sizeof(Vertex),(void *)offsetof(Vertex,Normal));
            
            glEnableVertexAttribArray(2);
            glVertexAttribPointer(2,2,GL_FLOAT,GL_FALSE,sizeof(Vertex),(void *)offsetof(Vertex,TexCoords));
            
            glEnableVertexAttribArray(3);
            glVertexAttribPointer(3,3,GL_FLOAT,GL_FALSE,sizeof(Vertex),(void *)offsetof(Vertex,Tangent));
            
            glEnableVertexAttribArray(4);
            glVertexAttribPointer(4,3,GL_FLOAT,GL_FALSE,sizeof(Vertex),(void *)offsetof(Vertex,Bitangent));
            
            glBindVertexArray(0);
        }
    };

};






#endif /* Mesh_h */
