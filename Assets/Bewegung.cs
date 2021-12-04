using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bewegung : MonoBehaviour
{
    public float speed;
    void Update()
    {
        transform.Translate(new Vector3(Input.GetAxis("Horizontal"), 0, Input.GetAxis("Vertical")) * Time.deltaTime * speed);
    }
}
