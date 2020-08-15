import InteractableObjectBase;
import PickupableObject.LockBase;

class ADoorBase:InteractableObjectBase
{

    UPROPERTY()
    bool ForceLocked=false;

    UPROPERTY()
    TArray<ALockBase> Locks;

    /*If true door will act as lock for itself*/
    UPROPERTY()
    bool SelfLock=false;

    UPROPERTY()
    bool OpenInInverse=false;

    UPROPERTY()
    int SelfLockKeyId=0;

    UPROPERTY()
    bool Locked=false;

    UPROPERTY()
    bool Opened=false;

    UPROPERTY()
    float MoveTime=1.2f;

     UPROPERTY(DefaultComponent)
    UAudioComponent MoveSound;
    default MoveSound.Sound = Asset("/Game/Sounds/hl2/doors/wood_move1.wood_move1");
    default MoveSound.AutoActivate=false;

    UPROPERTY(DefaultComponent)
    UAudioComponent MoveStopSound;
    default MoveStopSound.Sound = Asset("/Game/Sounds/hl2/doors/wood_stop1.wood_stop1");
    default MoveStopSound.AutoActivate=false;

    UPROPERTY(DefaultComponent)
    UAudioComponent LockedSound;
    default LockedSound.Sound = Asset("/Game/Sounds/hl2/doors/default_locked.default_locked");
    default LockedSound.AutoActivate=false;

    UPROPERTY(DefaultComponent)
    UAudioComponent UnLockedSound;
    default UnLockedSound.Sound = Asset("/Game/Sounds/Lock/lock_creaking.lock_creaking");
    default UnLockedSound.AutoActivate=false;


    FTimerHandle MovementTimer;
    
    UPROPERTY(DefaultComponent,RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent, Attach=Root)
    UStaticMeshComponent Mesh;
    default Mesh.StaticMesh = Asset("/Game/ScienceLab/Meshes/Rooms/Doors/SM_Door01.SM_Door01");

    /* The overridden construction script will run when needed. */
	UFUNCTION(BlueprintOverride)
	void ConstructionScript()
	{       
        
        /*If we have lock that means door must be locked*/
        if(Locks.Num()>0)
        {
            Locked = true;
        }

		if(!Locked)
        {
            if(Opened)
            {
              
                Mesh.SetRelativeRotation(FRotator(0,OpenInInverse?-90:90,0));               
            }
        }
	}

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        if(System::TimerExistsHandle(MovementTimer))
        {
            float Percent = System::GetTimerElapsedTimeHandle(MovementTimer)/MoveTime;
            if(Opened)
            {
                Mesh.SetRelativeRotation(FRotator(0,(OpenInInverse?-90:90)-((OpenInInverse?-90:90)*Percent),0));
               
            }
            else
            {
                Mesh.SetRelativeRotation(FRotator(0,(OpenInInverse?-90:90)*Percent,0));
                  
            }
        }
    }

    //toggles state of the door
    UFUNCTION()
    void Open()
    {
        if(!ForceLocked)
        {
            Locked=false;
            if(Locks.Num()>0)
            {
                for(int i=0;i<Locks.Num();i++)
                {
                    if(Locks[i].Locked){Locked = true;break;}
                }
            }
            if(!System::TimerExistsHandle(MovementTimer))
            {
                if(!Locked)
                {
                    MoveSound.Play();
                    MovementTimer = System::SetTimer(this,n"FinishedMovement",MoveTime,false);
                }
                else
                {
                    LockedSound.Play();
                }
            }
        }
    }

    //unlike open function which toggles state of this door, this one force closes it
    UFUNCTION()
    void Close()
    {
        if(Opened)
        {
            Open();
        }
    }

     UFUNCTION()
     void FinishedMovement()
     {
         MoveStopSound.Play();
         Opened=!Opened;
     }

    UFUNCTION(BlueprintOverride)
    void OnInteraction(AActor Interactor, UActorComponent InteractedComponent) override
    {
        if(SelfLock&&Cast<AKey>(Interactor)!=nullptr)
        {
            int id = Cast<AKey>(Interactor).KeyId;
            if(id==SelfLockKeyId||id==-1)
            {               
                Locked = false;
                UnLockedSound.Play();
            }
        }
        Open();
    }
}