
using UnityEngine;

public class FPS : MonoBehaviour
{
    private Rect labelRect = new Rect(400, 00, 100, 100);
    private Rect labelRect2 = new Rect(400, 100, 100, 100);
    GUIStyle Style = new GUIStyle();
    private float _Interval = 0.5f;
    private int _FrameCount = 0;
    private float _TimeCount = 0;
    private float _FrameRate = 0;
    void Awake()
    {
        Style.fontSize = 100;
        Application.targetFrameRate = 1000;
    }
    void Update()
    {
        _FrameCount++;
        _TimeCount += Time.unscaledDeltaTime;
        if (_TimeCount >= _Interval)
        {
            _FrameRate = _FrameCount / _TimeCount;
            _FrameCount = 0;
            _TimeCount -= _Interval;
        }
    }

    void OnGUI()
    {
        GUI.Label(labelRect, string.Format("FPS£º{0:F1}", _FrameRate), Style);
        GUI.Label(labelRect2, Screen.width + " * " +  Screen.height, Style);
    }
}