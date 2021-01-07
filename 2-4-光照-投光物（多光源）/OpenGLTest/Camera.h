//
//  Camera.h
//  OpenGLTest
//
//  Created by Zero on 2020/12/11.
//  Copyright © 2020 Lenz. All rights reserved.
//

#ifndef Camera_h
#define Camera_h

#include <glad/glad.h>
#include <string>
#include <fstream>
#include <sstream>
#include <iostream>

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

enum Camera_Movement {
    FORWARD,
    BACKWARD,
    LEFT,
    RIGHT
};

const float YAW = -90;
const float PITCH = 0.0f;
const float SPEED = 2.5f;
const float SENSITIVITY = 0.1f;
const float ZOOM = 45.0f;

class Camera {
public:
    glm::vec3 Position;
    glm::vec3 Front;
    glm::vec3 Up;
    glm::vec3 Right;
    glm::vec3 WorldUp;
    
    float Yaw;
    float Pitch;
    
    float MovementSpeed;
    float MouseSensitivity;
    float Zoom;
    
    Camera(glm::vec3 position = glm::vec3(0.0f,0.0f,0.0f),glm::vec3 up = glm::vec3(0.0f,1.0f,0.0f),float yaw = YAW,float pitch = PITCH) : Front(glm::vec3(0.0f,0.0f,-1.0f)),MovementSpeed(SPEED),MouseSensitivity(SENSITIVITY),Zoom(ZOOM) {
        Position = position;
        WorldUp = up;
        Yaw = yaw;
        Pitch = pitch;
        
        updateCameraVectors();
    }
    
    
    Camera(float posX,float posY,float posZ,float upX,float upY,float upZ,float yaw,float pitch): Front(glm::vec3(0.0f,0.0f,-1.0f)),MovementSpeed(SPEED),MouseSensitivity(SENSITIVITY),Zoom(ZOOM) {
        Position = glm::vec3(posX,posY,posZ);
        WorldUp = glm::vec3(upX,upY,upZ);
        Yaw = yaw;
        Pitch = pitch;
        updateCameraVectors();

    }
    
    glm::mat4 GetViewMatrix() {
        //looktAt参数：摄像机位置P 目标位置 世界空间的上向量
        //摄像机位置和目标位置 可以算出 摄像机方向D （这个方向和摄像机对着的方向是相反的）
        //上向量 和 摄像机方向 叉乘可以算出 右轴R
        //摄像机方向 和 右轴 叉乘可以算出 上轴U
        //LootAt 通过上面的向量可以构建一个矩阵
        /*
         
            |Rx Ry Rz 0|   |1 0 0 -Px|
            |Ux Uy Uz 0|   |0 1 0 -Py|
            |Dx Dy Dz 0| * |0 0 1 -Pz|
            |0  0  0  1|   |0 0 0  1 |
         */
        //https://learnopengl-cn.github.io/01%20Getting%20started/09%20Camera/
        
//        return lookAt(Position, Position + Front, Up);
        return glm::lookAt(Position, Position + Front, Up);
    }
    
    void ProcessKeyboard(Camera_Movement direction,float deltaTime) {
        float velocity = MovementSpeed * deltaTime;
        if (direction == FORWARD) {
            Position += Front * velocity;
        }
        if (direction == BACKWARD) {
            Position -= Front * velocity;
        }
        if (direction == LEFT) {
            Position -= Right * velocity;
        }
        if (direction == RIGHT) {
            Position += Right * velocity;
        }
        
        Position.y = 0.0f;
    }
    
    void ProcessMouseMovement(float xoffset,float yoffset,GLboolean constrainPitch = true) {
        xoffset *= MouseSensitivity;
        yoffset *= MouseSensitivity;
        
        Yaw += xoffset;
        Pitch += yoffset;
        
        if (constrainPitch) {
            if (Pitch > 89.0f) {
                Pitch = 89.0f;
            }
            if (Pitch < -89.0f) {
                Pitch = -89.0f;
            }
        }
        
        updateCameraVectors();
    }
    
    void ProcessMouseScroll(float yoffset) {
        Zoom -= (float)yoffset;
        if (Zoom < 1.0f) {
            Zoom = 1.0f;
        }
        if (Zoom > 45.0f) {
            Zoom = 45.0f;
        }
    }
    
private:
    void updateCameraVectors() {
        glm::vec3 front;
        front.x = cos(glm::radians(Yaw)) * cos(glm::radians(Pitch));
        front.y = sin(glm::radians(Pitch));
        front.z = sin(glm::radians(Yaw)) * cos(glm::radians(Pitch));
        Front = glm::normalize(front);
        
        Right = glm::normalize(glm::cross(Front, WorldUp));
        Up = glm::normalize(glm::cross(Front, Right));
    }
    
    glm::mat4 lookAt(glm::vec3 position,glm::vec3 target,glm::vec3 worldUp) {
       glm::vec3 right(1.0);
       glm::vec3 up(1.0);
       glm::vec3 direction(1.0);
       direction = glm::normalize(position - target);
       right = glm::normalize(glm::cross(direction, WorldUp));
       up = glm::cross(direction, right);
       glm::mat4 rotation(1.0f);
       rotation[0][0] = right.x;
       rotation[1][0] = right.y;
       rotation[2][0] = right.z;

       rotation[0][1] = up.x;
       rotation[1][1] = up.y;
       rotation[2][1] = up.z;
       
       rotation[0][2] = direction.x;
       rotation[1][2] = direction.y;
       rotation[2][2] = direction.z;
       
       
       glm::mat4 translation(1.0f);
       translation[3][0] = -position.x;
       translation[3][1] = -position.y;
       translation[3][2] = -position.z;
       
       return rotation * translation;
    }
};

#endif /* Camera_h */
