using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AboutVFXGhostAnimClipEvent : MonoBehaviour
{

    Dictionary<string, AboutVFXGhostTrail.EventData> datas = new Dictionary<string, AboutVFXGhostTrail.EventData>();
    public void AddEvent(AboutVFXGhostTrail.EventData eventData)
    {
        datas.Add(eventData.Key, eventData);
    }

    public void AnimClipEvent(string key)
    {
        AboutVFXGhostTrail.EventData targetData;
        datas.TryGetValue(key,out targetData);
        if (targetData!=null)
        {
            targetData.Triger();
            datas.Remove(key);
        }
        if (datas.Count==0)
        {
            Destroy(this);
        }
    }
}
