using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 药剂动画
/// </summary>
public class LiquidAnim : MonoBehaviour
{
    Transform _tranform;

    Material mat;

    private void Start()
    {
        _tranform = transform;
        xyPos.x = _tranform.position.x;
        xyPos.y = _tranform.position.z;
        curPos.x = _tranform.position.x;
        curPos.y = _tranform.position.z;
        try
        {
            UnityEngine.Renderer renderer = gameObject.GetComponent<MeshRenderer>();
            if (renderer == null)
            {
                renderer = gameObject.GetComponent<SkinnedMeshRenderer>();
            }
            mat = Instantiate(renderer.sharedMaterial);
            renderer.sharedMaterial = mat;
            baseMapStrengthStart = mat.GetFloat(string.Intern("_BaseMapStrength"));
            if (baseMapStrengthStart!=0)
            {
                mat.SetFloat(string.Intern("_BaseMapStrength"), baseMapStrengthStart);
            }
            else
            {
                mat.SetFloat(string.Intern("_BaseMapStrength"), 0f);
            }
            mat.SetFloat(string.Intern("_WobbleX"),0);
            mat.SetFloat(string.Intern("_WobbleZ"), 0);
            mat.SetFloat(string.Intern("_Rotation"), 90);
        }
        catch (System.Exception ex)
        {
            UnityEngine.Debug.LogException(ex);
        }
    }

    private void OnDestroy()
    {
        if (mat!=null)
        {
            Destroy(mat);
        }
    }

    private void Update()
    {
        ChangeDetection();
    }

    float baseMapStrengthStart;

    Vector2 xyPos;

    Vector2 curPos;

    Vector2 speedDir;

    float shakeTimeLenght = 0.7f;

    float setShakeTimeLenght;

    float shakeTime;

    float strength;

    float speedTimeLenght = 0;

    /// <summary>
    /// 变动检测 XZ轴的位移速度
    /// </summary>
    void ChangeDetection()
    {
        if (mat == null || mat.shader == null || mat.shader.name.CompareTo(string.Intern("NewRender/Liquid/Default")) != 0)
        {
            return;
        }
        curPos.x = _tranform.position.x;
        curPos.y = _tranform.position.z;
        speedDir = curPos - xyPos;
        if (speedDir!=Vector2.zero)
        {
            setShakeTimeLenght = UnityEngine.Mathf.Lerp(0f, shakeTimeLenght,Mathf.Min(0.2f, speedTimeLenght)/ 0.2f);
            shakeTime = setShakeTimeLenght;
            //位移操作
            mat.SetFloat(string.Intern("_WobbleX"),System.Math.Clamp(-speedDir.x,-0.5f,0.5f));
            mat.SetFloat(string.Intern("_WobbleZ"), System.Math.Clamp(-speedDir.y, -0.5f, 0.5f));
            xyPos = curPos;
            speedTimeLenght = speedTimeLenght + Time.deltaTime;
        }
        else
        {
            speedTimeLenght = 0;
            if (xyPos!= curPos)
            {
                strength = setShakeTimeLenght/ shakeTimeLenght;
            }
            xyPos = curPos;

            if (shakeTime>0)
            {
                shakeTime = shakeTime - Time.deltaTime;
                if (shakeTime<=0.001f)
                {
                    shakeTime = 0;
                }
                float r = UnityEngine.Mathf.Sin(shakeTime*25f* strength)* strength * 0.5f+0.5f;
                mat.SetFloat(string.Intern("_Rotation"), UnityEngine.Mathf.Lerp(80f, 100f, r));
                mat.SetFloat(string.Intern("_WobbleX"), UnityEngine.Mathf.Lerp(-0.2f , 0.2f , r));
                mat.SetFloat(string.Intern("_WobbleZ"), UnityEngine.Mathf.Lerp(-0.2f , 0.2f , r));
                if (baseMapStrengthStart!=0)
                {
                    mat.SetFloat(string.Intern("_BaseMapStrength"), UnityEngine.Mathf.Lerp(-baseMapStrengthStart, baseMapStrengthStart, r) + baseMapStrengthStart);
                }
                else
                {
                    mat.SetFloat(string.Intern("_BaseMapStrength"), UnityEngine.Mathf.Lerp(-baseMapStrengthStart, baseMapStrengthStart, r));
                }
                strength = UnityEngine.Mathf.Lerp(0.3f, 1f, shakeTime/ setShakeTimeLenght);
            }
        }
    }
}
