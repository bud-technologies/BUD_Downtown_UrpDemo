
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;

/// <summary>
/// 材质shader中需要有属性 “_Opacity” 用于控制透明度
/// </summary>
public class AboutVFXGhostTrail : MonoBehaviour {

	public bool openGhostTrail = false;

	[Header("需要控制的网格")]
	public List<VFXData> Datas = new List<VFXData>();

	[Header("残影分身的时间间隔(秒)")]
	[Range(0.05f, 0.5f)]
	public float intervalTime = 0.2f;

	[Header("残影生命周期(秒)")]
	[Range(0.1f, 1.0f)]
	public float lifeTime = 0.5f;

	[Header("残影淡入淡出(秒)")]
	[Range(0.1f, 1.0f)]
	public float fadeTime = 0.3f;

	[Header("启动关闭事件列表")]
	public List<EventData> EventList = new List<EventData>();

	private List<EventData> timeDelayEventList = new List<EventData>();

	private float updateTime = 0f;

	private List<AboutVFXGhostItem> ghostList = new List<AboutVFXGhostItem>();

	public bool open = false;

	void OnEnable() {

		//UnityEngine.Rendering.CompareFunction
		bool findOpenEvent = false;
        for (int i=0,listCount= Datas.Count;i< listCount;++i)
        {
            if (Datas[i].SkinnedMeshRenderer==null || Datas[i].GhostMaterial==null)
            {
				Datas.RemoveAt(i);
				listCount--;
				i--;
			}
            else
            {
				//Datas[i].OpacityName = Datas[i].OpacityName.Trim();
				//if (string.IsNullOrEmpty(Datas[i].OpacityName))
				//{
				//    Datas[i].OpacityName = "_Opacity";
				//}
				Datas[i].OpacityName = "_Opacity";
				Datas[i].ShaderOpacityId = Shader.PropertyToID(Datas[i].OpacityName);
                if (Datas[i].ShaderOpacityId<0)
                {
					Datas.RemoveAt(i);
					listCount--;
					i--;
				}
			}
        }
        for (int i=0,listCount= EventList.Count;i< listCount;++i)
        {
			EventData eventData = EventList[i];
			bool bl = eventData.Init(this);
			switch (eventData.TrigerMod)
            {
				case TrigerMod.DelayTime:
                    {
						timeDelayEventList.Add(eventData);
					}
					break;
				case TrigerMod.AnimClipTrigger:
					{

					}
					break;
			}
            if (bl)
            {
				if (eventData.EventType == EventType.Open)
				{
					findOpenEvent = true;
				}
            }
            else
            {
				EventList.RemoveAt(i);
				listCount--;
				i--;
			}
		}
        if (!findOpenEvent)
        {
			Open();
		}
	}

	private void OnDisable()
    {
		Clear();
    }

    void LateUpdate () {
		if (Datas.Count == 0) return;
        if (timeDelayEventList.Count>0)
        {
            for (int i=0,listCount= timeDelayEventList.Count;i< listCount;++i)
            {
				EventData eventData = timeDelayEventList[i];
				eventData.DelayTimeRun = eventData.DelayTimeRun - Time.deltaTime;
                if (eventData.DelayTimeRun <= 0)
                {
					timeDelayEventList.Remove(eventData);
					listCount--;
					i--;
					eventData.Triger();
				}
			}
        }

		if (openGhostTrail == true && open)
		{
			updateTime += Time.deltaTime;
			if (updateTime >= intervalTime)
			{
				updateTime = 0f;
				CreateGhostItem();
			}
		}

		if (ghostList.Count > 0)
		{
			FadeGhostItem();
			DrawGhostItem();
		}

	}

	void Open() {
		open = true;
	}

	void Close()
    {
		open = false;
	}

	bool isInitAnimClips = false;

	public Dictionary<string, AnimationClipData> animClips = new Dictionary<string, AnimationClipData>();

	public void InitAnimClips()
    {
		if (isInitAnimClips) return;
		isInitAnimClips = true;
		Animation[] animations = gameObject.GetComponentsInChildren<Animation>(true);
        for (int i=0,listCount= animations.Length;i< listCount;++i)
        {
			Animation animation = animations[i];
			IEnumerator ienumerator = animation.GetEnumerator();
            while (ienumerator.MoveNext())
            {
				AnimationState animationState = (AnimationState)ienumerator.Current;
                if (animationState.clip!=null && !animClips.ContainsKey(animationState.clip.name))
                {
					AnimationClipData data = new AnimationClipData();
					data.AnimationClip = animationState.clip;
					data.Target = animation.transform;
					animClips.Add(animationState.clip.name, data);
				}
			}
		}
		Animator[] animators = gameObject.GetComponentsInChildren<Animator>(true);
        for (int i=0,listCount= animators.Length;i< listCount;++i)
        {
			Animator animator = animators[i];
			int layerCount = animator.layerCount;
            for (int j=0;j< layerCount;++j)
            {
				AnimatorClipInfo[] infos = animator.GetCurrentAnimatorClipInfo(j);
				for (int x=0;x< infos.Length;++x) {
					AnimatorClipInfo info = infos[x];
                    if (info.clip!=null && !animClips.ContainsKey(info.clip.name))
                    {
						AnimationClipData data = new AnimationClipData();
						data.AnimationClip = info.clip;
						data.Target = animator.transform;
						animClips.Add(info.clip.name, data);
					}
				}
			}
		}
	}

	void Clear()
    {
		Dictionary<string, AnimationClipData>.Enumerator enumerator = animClips.GetEnumerator();
		while (enumerator.MoveNext())
		{
			AnimationClipData animationClipData = enumerator.Current.Value;
			AboutVFXGhostAnimClipEvent aboutVFXGhostAnimClipEvent = animationClipData.Target.GetComponent<AboutVFXGhostAnimClipEvent>();
			if (aboutVFXGhostAnimClipEvent != null)
			{
				Destroy(aboutVFXGhostAnimClipEvent);
			}
			AnimationEvent[] events = animationClipData.AnimationClip.events;
			List<AnimationEvent> list = new List<AnimationEvent>();
			for (int i = 0, listCount = events.Length; i < listCount; ++i)
			{
				AnimationEvent animationEvent = events[i];
				if (!animationEvent.stringParameter.EndsWith("_AboutVFXGhostAnimClipEvent"))
				{
					list.Add(animationEvent);
				}
			}
			animationClipData.AnimationClip.events = list.ToArray();
		}
		animClips.Clear();
		timeDelayEventList.Clear();
		updateTime = 0f;
		open = false;
		isInitAnimClips = false;
	}

    private void OnDestroy()
    {
		Clear();
		for (int i = 0,listCount= ghostList.Count; i < listCount;++i)
		{
			Destroy(ghostList[i].Mesh);
			Destroy(ghostList[i].Mat);
			ghostList.RemoveAt(i);
		}
		ghostList.Clear();
	}

    void CreateGhostItem(){
        for (int i=0,listCount= Datas.Count;i< listCount;++i)
        {
			VFXData vfxData = Datas[i];
			Mesh GhostMesh = new Mesh();
			vfxData.SkinnedMeshRenderer.BakeMesh(GhostMesh);
			ghostList.Add(new AboutVFXGhostItem(GhostMesh, vfxData.SkinnedMeshRenderer.transform.localToWorldMatrix, new Material(vfxData.GhostMaterial), vfxData.ShaderOpacityId));
		}
	}

	void FadeGhostItem(){
		for (int i = (ghostList.Count-1);i>=0;i--) {
			if (ghostList[i].Age > lifeTime) {
				ghostList[i].FadeLerp += (1 / fadeTime) * Time.deltaTime;
				ghostList[i].Alpha = Mathf.Lerp (1f, 0f, ghostList [i].FadeLerp);
				if (ghostList [i].FadeLerp > 1) {
					Destroy (ghostList [i].Mesh);
					Destroy (ghostList [i].Mat);
					ghostList.RemoveAt (i);
				} else {
					ghostList[i].Mat.SetFloat(ghostList[i].ShaderOpacityId, ghostList[i].Alpha);
		
				}
			} 
		}
	}

	void DrawGhostItem(){
		foreach (AboutVFXGhostItem item in ghostList) {
			item.Age+=Time.deltaTime;
			Graphics.DrawMesh(item.Mesh, item.Matrix, item.Mat, gameObject.layer);
		}
	}

	[Serializable]
	public class VFXData
    {
		[HideInInspector]
		/// <summary>
		/// 透明度ID
		/// </summary>
		public int ShaderOpacityId = -1;

		[HideInInspector]
		[Header("透明度属性值,可手动填，默认=_Opacity")]
		public string OpacityName = "_Opacity";

		[Header("蒙皮网格")]
		public SkinnedMeshRenderer SkinnedMeshRenderer;

		[Header("显示材质")]
		public Material GhostMaterial;
	}

	[Serializable]
	public class EventData
    {
		[HideInInspector]
		[Header("动画触发关键字")]
		public string Key = "";

		[Header("事件类型")]
		public EventType EventType;

		[Header("触发类型")]
		public TrigerMod TrigerMod;

		[Header("动画触发时的动画名")]
		public string AnimtionClipName = "";

		[Header("时间延迟触发时的延迟/动画触发的时间(秒)")]
		public float DelayTime = 0;

		[HideInInspector]
		public float DelayTimeRun = 0;

		AboutVFXGhostTrail aboutVFXGhostTrail;

		[HideInInspector]
		public AnimationClip animationClip;

		public bool Init(AboutVFXGhostTrail _aboutVFXGhostTrail)
        {
			aboutVFXGhostTrail = _aboutVFXGhostTrail;
			DelayTimeRun = DelayTime;
			switch (TrigerMod)
            {
				case TrigerMod.AnimClipTrigger:
                    {
						//绑定动画事件
						aboutVFXGhostTrail.InitAnimClips();
						AnimtionClipName = AnimtionClipName.Trim();
                        if (aboutVFXGhostTrail.animClips.ContainsKey(AnimtionClipName))
                        {
							AnimationClipData animationClipData= aboutVFXGhostTrail.animClips[AnimtionClipName];
							AnimationClip animClip = animationClipData.AnimationClip;
							animationClip = animClip;
							AboutVFXGhostAnimClipEvent aboutVFXGhostAnimClipEvent = animationClipData.Target.GetComponent<AboutVFXGhostAnimClipEvent>();
                            if (aboutVFXGhostAnimClipEvent==null)
                            {
								aboutVFXGhostAnimClipEvent = animationClipData.Target.gameObject.AddComponent<AboutVFXGhostAnimClipEvent>();
							}
							Key = System.Guid.NewGuid().ToString()+ "_AboutVFXGhostAnimClipEvent";
							aboutVFXGhostAnimClipEvent.AddEvent(this);
							AnimationEvent evt = new AnimationEvent();
                            if (DelayTime < 0)
                            {
								DelayTime = 0;
							}
                            if (DelayTime > animationClip.length)
                            {
								DelayTime = animationClip.length;
							}
							evt.time = DelayTime;
							evt.stringParameter = Key;
							evt.functionName = "AnimClipEvent";
							animClip.AddEvent(evt);
						}
                        else
                        {
							return false;
                        }
					}
					break;
            }
			return true;
		}

		public void Triger()
        {
            if (animationClip!=null)
            {
				AnimationEvent[] events = animationClip.events;
				List<AnimationEvent> list = new List<AnimationEvent>();
                for (int i=0,listCount= events.Length;i< listCount;++i)
                {
					AnimationEvent animationEvent = events[i];
                    if (animationEvent.stringParameter.CompareTo(Key) !=0)
                    {
						list.Add(animationEvent);
					}
				}
				animationClip.events = list.ToArray();
			}
            switch (EventType)
            {
				case EventType.Open:
                    {
						aboutVFXGhostTrail.Open();
					}
					break;
				case EventType.Close:
					{
						aboutVFXGhostTrail.Close();
					}
					break;
			}

        }

	}

	public class AnimationClipData
    {
		public AnimationClip AnimationClip;

		public Transform Target;
	}

	public enum EventType
    {
		[Header("启动事件")]
		Open,
		[Header("关闭事件")]
		Close,
    }

	public enum TrigerMod
    {
		[Header("时间延迟")]
		DelayTime,
		[Header("动画触发")]
		AnimClipTrigger,
    }

}