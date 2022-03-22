//
//  Camera.h
//  OpenGLTest
//
//  Created by Zero on 2020/12/11.
//  Copyright © 2020 Lenz. All rights reserved.
//

#ifndef Camera_h
#define Camera_h

#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#include <string>
#include <fstream>
#include <sstream>
#include <iostream>

#include <cglm/cglm.h>


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

vec3 zero = {0.0,0.0,0.0};
vec3 identity = {0.0,1.0,0.0};

class Camera {
public:
    vec3 Position;
    vec3 Front;
    vec3 Up;
    vec3 Right;
    vec3 WorldUp;
    
    float Yaw;
    float Pitch;
    
    float MovementSpeed;
    float MouseSensitivity;
    float Zoom;
    Camera(vec3 position = zero,vec3 up = identity,float yaw = YAW,float pitch = PITCH) : Front{0.0f,0.0f,-1.0f},MovementSpeed(SPEED),MouseSensitivity(SENSITIVITY),Zoom(ZOOM) {
        glm_vec3_copy(position, Position);
        glm_vec3_copy(up, WorldUp);
        Yaw = yaw;
        Pitch = pitch;
        
        updateCameraVectors();
    }
    
    
    Camera(float posX,float posY,float posZ,float upX,float upY,float upZ,float yaw,float pitch): Front{0.0f,0.0f,-1.0f},MovementSpeed(SPEED),MouseSensitivity(SENSITIVITY),Zoom(ZOOM) {
        vec3 p = {posX,posY,posZ};
        glm_vec3_copy(p, Position);
        vec3 up = {upX,upY,upZ};
        glm_vec3_copy(up, WorldUp);
        Yaw = yaw;
        Pitch = pitch;
        updateCameraVectors();

    }
    
    void GetViewMatrix(mat4 dst) {
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
        vec3 d;
        glm_vec3_copy(zero, d);
        glm_vec3_add(Position, Front, d);
        glm_lookat(Position, d, Up, dst);
    }
    
//    void ProcessKeyboard(Camera_Movement direction,float deltaTime) {
//        float velocity = MovementSpeed * deltaTime;
//        if (direction == FORWARD) {
//            Position += Front * velocity;
//        }
//        if (direction == BACKWARD) {
//            Position -= Front * velocity;
//        }
//        if (direction == LEFT) {
//            Position -= Right * velocity;
//        }
//        if (direction == RIGHT) {
//            Position += Right * velocity;
//        }
//
//        Position.y = 0.0f;
//    }
    
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
        vec3 front;
        front[0] = cos(glm_rad(Yaw)) * cos(glm_rad(Pitch));
        front[1] = sin(glm_rad(Pitch));
        front[2] = sin(glm_rad(Yaw)) * cos(glm_rad(Pitch));
        glm_normalize(front);
        glm_vec3_copy(front, Front);
        
        
        vec3 r;
        glm_cross(Front, WorldUp, r);
        glm_normalize(r);
        glm_vec3_copy(r, Right);

        vec3 u;
        glm_cross(Front, Right, u);
        glm_normalize(u);
        glm_vec3_copy(u, Up);
    }
    
//    lookAt(glm::vec3 position,glm::vec3 target,glm::vec3 worldUp, mat4 dst) {
//       glm::vec3 right(1.0);
//       glm::vec3 up(1.0);
//       glm::vec3 direction(1.0);
//       direction = glm::normalize(position - target);
//       right = glm::normalize(glm::cross(direction, WorldUp));
//       up = glm::cross(direction, right);
//       glm::mat4 rotation(1.0f);
//       rotation[0][0] = right.x;
//       rotation[1][0] = right.y;
//       rotation[2][0] = right.z;
//
//       rotation[0][1] = up.x;
//       rotation[1][1] = up.y;
//       rotation[2][1] = up.z;
//       
//       rotation[0][2] = direction.x;
//       rotation[1][2] = direction.y;
//       rotation[2][2] = direction.z;
//       
//       
//       glm::mat4 translation(1.0f);
//       translation[3][0] = -position.x;
//       translation[3][1] = -position.y;
//       translation[3][2] = -position.z;
//       
//       return rotation * translation;
//    }
};

#endif /* Camera_h */
