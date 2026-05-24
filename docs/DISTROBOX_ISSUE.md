```terraform
   resource "docker_container" "workspace" {                                                   
     image = "your-devcontainer-image:tag"                                                     
     name  = "coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}"          
                                                                                               
     # Add these:                                                                              
     privileged = true                                                                         
                                                                                               
     security_opts = [                                                                         
       "apparmor=unconfined",                                                                  
       "seccomp=unconfined",                                                                   
     ]                                                                                         
                                                                                               
     capabilities {                                                                            
       add = ["SYS_ADMIN", "SETUID", "SETGID"]                                                 
     }                                                                                         
                                                                                               
     # Your existing mounts...                                                                 
     volumes {                                                                                 
       host_path      = "/home/coder"                                                          
       container_path = "/home/coder"                                                          
     }                                                                                         
   }  
```