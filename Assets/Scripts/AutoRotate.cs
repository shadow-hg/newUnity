using System.Collections;
using UnityEngine;

//[ExecuteAlways]
public class AutoRotate : MonoBehaviour
{
    //public GameObject newGameObject;
    public float speed;

    private float _angleAxis;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        //_angleAxis += Time.deltaTime * speed;
        this.transform.Rotate(Vector3.up,Time.deltaTime * speed);
    }
}
