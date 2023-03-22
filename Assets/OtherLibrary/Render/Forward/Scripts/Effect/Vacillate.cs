using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace UnityRender
{
    /// <summary>
    /// Ò¡°Ú
    /// </summary>
    public class Vacillate : MonoBehaviour
    {

        public AxialDirection Axial;

        public float Speed=1f;

        public float Angle = 30f;

        float curTime=0;

        public float WaitTimeLenght = 1f;

        float curWaitTime = 0;

        private void Update()
        {
            if (curWaitTime>0)
            {
                curWaitTime = curWaitTime - Time.deltaTime;
                return;
            }
            curTime = curTime + Time.deltaTime;
            if (curTime>= Speed)
            {
                curTime = 0;
                curWaitTime = WaitTimeLenght;
            }
            float t = Mathf.Lerp(-3.1415926f*0.5f, 3.1415926f * 0.5f, curTime/ Speed);
            t = Mathf.Cos(t);
            t = Mathf.Lerp(0, Angle, t);
            switch (Axial)
            {
                case AxialDirection.X:
                    {
                        transform.localEulerAngles = new Vector3(t,0,0);
                    }
                    break;
                case AxialDirection.Y:
                    {
                        transform.localEulerAngles = new Vector3(0, t, 0);
                    }
                    break;
                case AxialDirection.Z:
                    {
                        transform.localEulerAngles = new Vector3(0, 0, t);
                    }
                    break;
            }
        }

        public enum AxialDirection
        {
            X,
            Y,
            Z,
        }
    }
}


