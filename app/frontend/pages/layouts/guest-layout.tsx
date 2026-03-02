import {toast, Toaster} from "sonner";
import {usePage} from "@inertiajs/react";
import {useEffect} from "react";


export default function GuestLayout({ children }: { children: React.ReactNode }) {

    const { flash } = usePage()

    useEffect(() => {
        if (flash?.notice)  {
            toast(flash.notice, { position: "top-center" })
        }
        if (flash?.alert)  {
            toast.error(flash.alert, { position: "top-center" })
        }
    }, [flash?.notice, flash?.alert])

    return <div>
        {children}
        <Toaster />
    </div>
}