//
//  AssimpModel.h
//  OpenGLTest
//
//  Created by Zero on 2021/1/11.
//  Copyright © 2021 Lenz. All rights reserved.
//

#ifndef AssimpModel_h
#define AssimpModel_h

#include <vector>
#include <string>
#include "Shader.h"
#include "Mesh.h"
#include <assimp/Importer.hpp>
#include <assimp/scene.h>
#include <assimp/postprocess.h>

using namespace std;
using namespace assimp;

unsigned int TextureFromFile(const char *path, const string &directory, bool gamma = false);

class Model {

public:
    Model(const char *path) {
        loadModel(path);
    }
    void Draw(Shader shader) {
        for (unsigned int i = 0; i < meshes.size(); i++) {
            meshes[i].Draw(shader);
        }
    }
private:
    vector<assimp::Mesh> meshes;
    string directory;
    
    vector<assimp::Texture> textures_loaded;

    
    void loadModel(string path) {
        Assimp::Importer importer;
        /*
         aiProcess_GenNormals：如果模型不包含法向量的话，就为每个顶点创建法线。
         aiProcess_SplitLargeMeshes：将比较大的网格分割成更小的子网格，如果你的渲染有最大顶点数限制，只能渲染较小的网格，那么它会非常有用。
         aiProcess_OptimizeMeshes：和上个选项相反，它会将多个小网格拼接为一个大的网格，减少绘制调用从而进行优化。
         */
        const aiScene *scene = importer.ReadFile(path, aiProcess_Triangulate | aiProcess_FlipUVs);
        
        if (!scene || scene->mFlags & AI_SCENE_FLAGS_INCOMPLETE || !scene->mRootNode) {
            cout << "ERROR::ASSIMP::" << importer.GetErrorString() << endl;
        }
        directory = path.substr(0,path.find_last_of('/'));
        
        processNode(scene->mRootNode, scene);
        
    }
    
    void processNode(aiNode *node,const aiScene *scene) {
        for (unsigned int i = 0; i < node->mNumMeshes; i++) {
            aiMesh *mesh = scene->mMeshes[node->mMeshes[i]];
            meshes.push_back(processMesh(mesh, scene));
        }
        
        for (unsigned int i = 0; i < node->mNumChildren; i++) {
            processNode(node->mChildren[i], scene);
        }
    }
    
    Mesh processMesh(aiMesh *mesh,const aiScene *scene) {
        std::vector<assimp::Vertex> vertices;
        std::vector<unsigned int> indices;
        std::vector<assimp::Texture> textures;
        
        for (unsigned int i = 0; i < mesh->mNumVertices; i++) {
            assimp::Vertex vertex;
            
            glm::vec3 vector;
            //位置
            vector.x = mesh->mVertices[i].x;
            vector.y = mesh->mVertices[i].y;
            vector.z = mesh->mVertices[i].z;
            vertex.Position = vector;
            
            //法线
            if (mesh->HasNormals())
           {
               vector.x = mesh->mNormals[i].x;
               vector.y = mesh->mNormals[i].y;
               vector.z = mesh->mNormals[i].z;
               vertex.Normal = vector;
           }
            
            //纹理坐标
            if(mesh->mTextureCoords[0]) // 网格是否有纹理坐标？
            {
                glm::vec2 vec;
                vec.x = mesh->mTextureCoords[0][i].x;
                vec.y = mesh->mTextureCoords[0][i].y;
                vertex.TexCoords = vec;
                
                // tangent
                if (mesh->mTangents) {
                    vector.x = mesh->mTangents[i].x;
                    vector.y = mesh->mTangents[i].y;
                    vector.z = mesh->mTangents[i].z;
                    vertex.Tangent = vector;
                }
                // bitangent
                if (mesh->mBitangents) {
                    vector.x = mesh->mBitangents[i].x;
                    vector.y = mesh->mBitangents[i].y;
                    vector.z = mesh->mBitangents[i].z;
                    vertex.Bitangent = vector;
                }

            }
            else {
                vertex.TexCoords = glm::vec2(0.0f, 0.0f);
            }
            
            vertices.push_back(vertex);
        }
        
        //索引
        for(unsigned int i = 0; i < mesh->mNumFaces; i++)
        {
            aiFace face = mesh->mFaces[i];
            for(unsigned int j = 0; j < face.mNumIndices; j++)
                indices.push_back(face.mIndices[j]);
        }
        
        //材质
        if(mesh->mMaterialIndex >= 0)
        {
            // 1. diffuse maps
            aiMaterial *material = scene->mMaterials[mesh->mMaterialIndex];
            vector<assimp::Texture> diffuseMaps = loadMaterialTextures(material,
                                                aiTextureType_DIFFUSE, "texture_diffuse");
            // 2. specular maps
            textures.insert(textures.end(), diffuseMaps.begin(), diffuseMaps.end());
            vector<assimp::Texture> specularMaps = loadMaterialTextures(material,
                                                aiTextureType_SPECULAR, "texture_specular");
            // 3. normal maps
            std::vector<Texture> normalMaps = loadMaterialTextures(material, aiTextureType_HEIGHT, "texture_normal");
            textures.insert(textures.end(), normalMaps.begin(), normalMaps.end());
            // 4. height maps
            std::vector<Texture> heightMaps = loadMaterialTextures(material, aiTextureType_AMBIENT, "texture_height");
            textures.insert(textures.end(), heightMaps.begin(), heightMaps.end());
            textures.insert(textures.end(), specularMaps.begin(), specularMaps.end());
        }

        
        return Mesh(vertices,indices,textures);
    }
    vector<assimp::Texture> loadMaterialTextures(aiMaterial *mat,aiTextureType type,string typeName) {
        vector<assimp::Texture> textures;
        for(unsigned int i = 0; i < mat->GetTextureCount(type); i++)
        {
            aiString str;
            mat->GetTexture(type, i, &str);
            bool skip = false;
            for (unsigned int j = 0; j < textures_loaded.size(); j++) {
                if (std::strcmp(textures_loaded[j].path.data, str.C_Str()) == 0) {
                    textures.push_back(textures_loaded[j]);
                    skip = true;
                    break;
                }
            }
            if (!skip) {
                assimp::Texture texture;
                texture.id = TextureFromFile(str.C_Str(), directory);
                texture.type = typeName;
                texture.path = str;
                textures.push_back(texture);
                textures_loaded.push_back(texture);
            }
        }
        return textures;
    }
};


unsigned int TextureFromFile(const char *path, const string &directory, bool gamma)
{
    string filename = string(path);
    filename = directory + '/' + filename;

    unsigned int textureID;
    glGenTextures(1, &textureID);

    int width, height, nrComponents;
    unsigned char *data = stbi_load(filename.c_str(), &width, &height, &nrComponents, 0);
    if (data)
    {
        GLenum format;
        if (nrComponents == 1)
            format = GL_RED;
        else if (nrComponents == 3)
            format = GL_RGB;
        else if (nrComponents == 4)
            format = GL_RGBA;

        glBindTexture(GL_TEXTURE_2D, textureID);
        glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, data);
        glGenerateMipmap(GL_TEXTURE_2D);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

        stbi_image_free(data);
    }
    else
    {
        std::cout << "Texture failed to load at path: " << path << std::endl;
        stbi_image_free(data);
    }

    return textureID;
}

#endif /* AssimpModel_h */
