import PickupableObject.StaticMeshPickableObject;

class APlank:AStaticMeshPickapableObject
{
    default Mesh.StaticMesh = Asset("/Engine/BasicShapes/Cone.Cone");
    default Mesh.SimulatePhysics=false;

}