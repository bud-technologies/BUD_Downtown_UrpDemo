using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 用于围绕指定轴旋转
/// </summary>
public class RotateFrom : MonoBehaviour
{
    public RotateEnum RotateEnumSet;

    public float Speed = 100;

    Transform _transform;
    void Start()
    {
        _transform = transform;
    }

    void Update()
    {
        switch (RotateEnumSet)
        {
            case RotateEnum.X:
                {
                    _transform.RotateAround(_transform.position, _transform.right, Speed*Time.deltaTime);
                }
                break;
            case RotateEnum.Y:
                {
                    _transform.RotateAround(_transform.position, _transform.forward, Speed * Time.deltaTime);
                }
                break;
            case RotateEnum.Z:
                {
                    _transform.RotateAround(_transform.position, _transform.up, Speed * Time.deltaTime);
                }
                break;
        }
        
    }

    public enum RotateEnum
    {
        X,
        Y,
        Z
    }
}
