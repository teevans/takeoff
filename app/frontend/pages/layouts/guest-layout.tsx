import {toast, Toaster} from "sonner";
import {usePage} from "@inertiajs/react";
import {useEffect} from "react";

interface PageProps {
    flash?: {
        notice?: string;
        alert?: string;
    }
    [key: string]: any
}

export default function GuestLayout({ children }: { children: React.ReactNode }) {

    const { props } = usePage<PageProps>()
    const flash = props.flash

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