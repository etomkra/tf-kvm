for VM_NAME in $(virsh list --name --all)
    do 
        virsh destroy --domain $VM_NAME
        virsh undefine --domain $VM_NAME --remove-all-storage
    done

for NET in $(virsh net-list --all --name | grep -v default )
    do 
        virsh net-undefine $NET; virsh net-destroy $NET
    done

for VOL in $(virsh vol-list ubuntu | grep  iso | awk '{ print $1}')
	do
		virsh vol-delete --pool ubuntu $VOL
	done

