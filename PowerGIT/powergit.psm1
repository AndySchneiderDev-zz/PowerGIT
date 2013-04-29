
Function Connect-GitRepository {
Param
    (
    [Parameter()]
    $Repository = (pwd).path
    )
$Script:repo = new-object LibGit2Sharp.Repository($Repository)

}

Function Get-GitLog {

    foreach ($commit in $repo.commits) 
    {
        $author = @{n="Name";e= {$_.Author.Name}}
        $when = @{n="When";e= {$_.Author.When}}
        $commit | Select Message, ID,$author,$when

    }


}

Function Get-GitTag {
Param
    (
    [Parameter()]
    $Tag = "*"
    )

    $repo.Tags | Where {$_.Name -like $Tag}

}

Function Add-GitFile {
Param
    (
    [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
    $File
    )
PROCESS {
    Try {
            $repo.Index.Stage((Resolve-Path $File).Path)
        }

    Catch {
            Write-Warning "Could not Add file $file"
        }
        }
}


Function Get-GitSignature {
$gitconfig = @{}

# Convert libGit2Sharp.Configuration to a hashtable
# so we can easily pull the user name and email
 foreach ($config in $repo.Config) 
    { 
        $gitconfig[$config.key] = $config.Value
    }
    
    $Name =  $gitconfig["user.name"]
    $Email = $gitconfig["user.email"]
    
    new-object LibGit2Sharp.Signature($Name,$Email,$(get-date))

}

Function Invoke-GitCommit{

Param
    (
    [Parameter(Mandatory=$True)]
    $Message
    )
    
    $sig = Get-GitSignature
    $repo.commit($Message,$sig,$sig)
  
}


Function New-GitBranch {
Param
    (
    [Parameter(Mandatory=$True)]
    [Alias("Name")]
    $Branch
    )
    
    $repo.Branches.Create($Branch,"HEAD",$false)


}

Function Connect-GitBranch {
Param
    (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [Alias("Name")]
    $Branch
    )
    
    [LibGit2Sharp.RepositoryExtensions]::Checkout($repo,$branch)

}


Function Add-GitTag {
Param
    (
    [Parameter(Mandatory=$True)]
    [Alias("Name")]
    $Tag,

    [Parameter(Mandatory=$True)]
    $Message
    )

    $sig = Get-GitSignature
    [LibGit2Sharp.RepositoryExtensions]::ApplyTag($repo,$tag,$sig,$Message)
   
}

#test

Function Get-GitStatus {
Param
    (
    [Parameter()]
    $File
    )

if ($file) 
    {
        $repo.Index.RetrieveStatus((Resolve-Path $File).Path)
    }
else 
    {
        $repo.Index.RetrieveStatus()
    }  
}

New-Alias Checkout-GitRepository Connect-GitRepository

Export-ModuleMember -Alias * -Function *
