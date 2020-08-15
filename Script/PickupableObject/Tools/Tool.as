import PickupableObject.StaticMeshPickableObject;
/*base for every class that player can use to help in game(like crowbar, axe, flashlight)*/
class AToolBase:AStaticMeshPickapableObject
{
      default Mesh.StaticMesh = Asset("/Engine/BasicShapes/Cone.Cone");
}