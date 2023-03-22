using UnityEngine;
using System;
using System.Collections;

namespace Render
{
    [Serializable]
    public class RGBCurve : ScriptableObject
    {
        public AnimationCurve R = new AnimationCurve();
        public AnimationCurve G = new AnimationCurve();
        public AnimationCurve B = new AnimationCurve();
        public float m_length = -1;

        public static float Max(float a, float b) { return a > b ? a : b; }

        public static float MaxTime(AnimationCurve curve)
        {
            if (curve == null || curve.length == 0)
                return 0f;

            int len = curve.length;
            Keyframe k = curve[len - 1];

            return k.time;
        }

        public float length
        {
            get
            {
                if (m_length == -1)
                {
                    float t0 = MaxTime(R);
                    float t1 = MaxTime(G);
                    float t2 = MaxTime(B);

                    m_length = Max(Max(t0, t1), t2);
                }

                return m_length;
            }
        }

        public Vector3 Eval(float time)
        {
            Vector3 v = new Vector3();

            v.x = R.Evaluate(time);
            v.y = G.Evaluate(time);
            v.z = B.Evaluate(time);

            return v;
        }
    }
}

