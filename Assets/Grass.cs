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
public class Grass : MonoBehaviour
{
    public Shader grassShader;

    [Header("Grass Settings")] public float planeSize = 50f;

    public int planeCount = 10;

    public float grassMaxHeight = 1.0f;
    public float grassMinHeight = .8f;
    public float density = 100f;
    public float thickness = 1f;
    public Color grassColor = Color.green;
    public Color grassBaseColor = Color.black;

    public int _seed;

    private RenderTexture interactionTexture;

    Mesh GeneratePlane(float size)
    {
        Mesh m = new Mesh();

        Vector3[] vertices = new Vector3[4];
        Vector2[] uv = new Vector2[4];
        int[] triangles = new int[6];

        vertices[0] = new Vector3(-size, 0, -size);
        vertices[1] = new Vector3(-size, 0, size);
        vertices[2] = new Vector3(size, 0, size);
        vertices[3] = new Vector3(size, 0, -size);

        uv[0] = new Vector2(0, 0);
        uv[1] = new Vector2(0, 1);
        uv[2] = new Vector2(1, 1);
        uv[3] = new Vector2(1, 0);

        triangles[0] = 0;
        triangles[1] = 1;
        triangles[2] = 2;
        triangles[3] = 0;
        triangles[4] = 2;
        triangles[5] = 3;

        m.vertices = vertices;
        m.uv = uv;
        m.triangles = triangles;

        m.RecalculateNormals();
        return m;
    }

    public void CreateResources()
    {
        _seed = Random.Range(0, 1) * 999999;

        Mesh m = GeneratePlane(planeSize);
        for (int i = 0; i < planeCount; i++)
        {
            GameObject plane = new GameObject();
            plane.transform.SetParent(this.transform, false);

            MeshRenderer mr = plane.AddComponent<MeshRenderer>();
            MeshFilter mf = plane.AddComponent<MeshFilter>();

            mf.mesh = m;
            mr.sharedMaterial = new Material(grassShader);

            mr.sharedMaterial.SetInt("_planeCount", planeCount);
            mr.sharedMaterial.SetInt("_planeIndex", i);
            mr.sharedMaterial.SetFloat("_density", density);
            mr.sharedMaterial.SetFloat("_grassMaxHeight", grassMaxHeight);
            mr.sharedMaterial.SetFloat("_grassMinHeight", grassMinHeight);
            mr.sharedMaterial.SetFloat("_thickness", thickness);
            mr.sharedMaterial.SetColor("_color", grassColor);
            mr.sharedMaterial.SetColor("_baseColor", grassBaseColor);
            mr.sharedMaterial.SetFloat("_seed", _seed);
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

[CustomEditor(typeof(Grass))]
public class GrassEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        Grass grass = (Grass)target;
        if (GUILayout.Button("Generate"))
        {
            grass.DestroyResources();
            grass.CreateResources();
        }
    }
}