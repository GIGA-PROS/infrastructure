let
  systems = {
    server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGkiKZm3S4Y+gnYAnMdag3IC5vbxnY0Ofmtty+FBnrsI";
  };
  users = {
    # PS: Benin's key is different than the SSH key he uses to login in the server, blame age + GPG
    benevides = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDR6iSCIEB9Ue5dL3KF/zRYhsoUlwuCDoozEKWTONIh1 leto@caladan";
    kanagawa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZudUl8jgFsOYouFL2jXFsADyDSKM0f8k/yCyVwlTMv2O3KTAN58OZcQP0NvaCE1xf0c8Z73sBDQE0LZcCuYvJv3Qfuiur2TOr0YgllnUz9XdkFWBNLykfcuOyo7Lvk0BQxXHJr2ADJVvfLRoaSpubYI40KYe2BJUXtwjUcLEUW8Pd9XknI59hCmgdJpWxotCWimGW5I+r8S5zEdTtMoJWMdDaAgzbw5AL+d227wTL0TKwA1LnCkAISgCCYcUGKG78Q8At1/gN/Q9Vl/v+CR9zYWiPgZihk2aK2LiYPPQbu5hhISyEnnJSIojDhZjCib+4Dt93bfKwMMKJxMF9XFeONINkecCyMOIIcfoGzRPoZNRyjc+TbHc84YuaizmJCHgD17dBnmxwZ75rMZHaKtGq4QJ+phP9bwP9oqAaTdDhFGcr1Ia4ozW2t1T3spDiVC3S5AxiwERLO15IDQwN8plJrIdR2lsQAs4dU3/uA5XEmcnPFVMy32fcKlUwJDMgGmM= mcosta@Marcoss-MacBook-Pro.local";
  };
  everyone = builtins.attrValues systems ++ builtins.attrValues users;
in
{
  "pg_master_password.age".publicKeys = everyone;
}
