using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEditor;
using UnityEngine.Serialization;
using Random = UnityEngine.Random;

[ExecuteInEditMode]
[RequireComponent(typeof(MeshFilter))]
public class Fur : MonoBehaviour
{
    public Shader shader;

    [Header("Fur Settings")]
    public int shellCount = 32;

    public float bladeMaxHeight = .1f;
    public float bladeMinHeight = .08f;
    public float density = 100f;
    public float thickness = 1f;
    public Color color = Color.green;
    public Color baseColor = Color.black;
    public float planeHeightExp = 2.0f;
    public float clumpDensity = 0.5f;
    public float curvature = 2.0f;
    public float ambientOcclusionFactor = 2.0f;
    
    private int _seed;

    private RenderTexture interactionTexture;

    public void CreateResources()
    {
        Mesh mesh;
        if (EditorApplication.isPlaying)
            mesh = GetComponent<MeshFilter>().mesh;
        else
             mesh = GetComponent<MeshFilter>().sharedMesh;
        
        _seed = Random.Range(0, 99999999);

        for (int i = 0; i < shellCount; i++)
        {
            GameObject plane = new GameObject();
            plane.transform.SetParent(this.transform, false);

            MeshRenderer mr = plane.AddComponent<MeshRenderer>();
            MeshFilter mf = plane.AddComponent<MeshFilter>();

            mf.mesh = mesh;
            mr.sharedMaterial = new Material(shader);

            mr.sharedMaterial.SetInt("_planeCount", shellCount);
            mr.sharedMaterial.SetInt("_planeIndex", i);
            mr.sharedMaterial.SetFloat("_density", density);
            mr.sharedMaterial.SetFloat("_maxHeight", bladeMaxHeight);
            mr.sharedMaterial.SetFloat("_minHeight", bladeMinHeight);
            mr.sharedMaterial.SetFloat("_thickness", thickness);
            mr.sharedMaterial.SetColor("_color", color);
            mr.sharedMaterial.SetColor("_baseColor", baseColor);
            mr.sharedMaterial.SetFloat("_seed", _seed);
            mr.sharedMaterial.SetFloat("_PlaneHeightExp", planeHeightExp);
            mr.sharedMaterial.SetFloat("_curvature", curvature);
            mr.sharedMaterial.SetFloat("_ambientOcclusionFactor", ambientOcclusionFactor);
        }
    }

    public void DestroyResources()
    {
        // Destroy all childrens
        for (int i = transform.childCount; i > 0; i--)
        {
            if (EditorApplication.isPlaying)
                Destroy(transform.GetChild(0).gameObject);
            else
                DestroyImmediate(transform.GetChild(0).gameObject);
        }
    }

    // Start is called before the first frame update
    void OnEnable()
    {
        CreateResources();
    }

    private void OnDisable()
    {
        DestroyResources();
    }

    // Update is called once per frame
    void Update()
    {
    }
}

[CustomEditor(typeof(Fur))]
public class FurEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        Fur grass = (Fur)target;
        if (GUILayout.Button("Generate"))
        {
            grass.DestroyResources();
            grass.CreateResources();
        }
    }
}