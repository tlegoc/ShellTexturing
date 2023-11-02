using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class CameraController : MonoBehaviour
{
    public float Speed = 7f;
    public float MouseSpeed = 1f;
    private float _yaw;
    private float _pitch;
    
    // Start is called before the first frame update
    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
    }

    // Update is called once per frame
    void Update()
    {
        if (Cursor.lockState != CursorLockMode.Locked) return;
        
        // rotation
        _yaw += MouseSpeed * Input.GetAxis("Mouse X");
        _pitch -= MouseSpeed * Input.GetAxis("Mouse Y");
        
        transform.eulerAngles = new Vector3(_pitch, _yaw, 0f);

        transform.position += (Speed * transform.forward * Input.GetAxis("Vertical") +
                              Speed * transform.right * Input.GetAxis("Horizontal")) * Time.deltaTime;
    }
}
