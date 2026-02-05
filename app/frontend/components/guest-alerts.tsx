import { Alert, AlertDescription } from "@/components/ui/alert"
import { CheckCircle2Icon } from "lucide-react"
import {usePage} from "@inertiajs/react";

function GuestAlerts() {
    const { flash } = usePage()
    return (
        <div>

            {flash?.notice && (
                <Alert className="max-w-md">
                    <CheckCircle2Icon />
                    <AlertDescription>
                        {flash?.notice}
                    </AlertDescription>
                </Alert>
            )}

            {flash?.alert && (
                <Alert variant="destructive" className="max-w-md">
                    <CheckCircle2Icon />
                    <AlertDescription>
                        {flash?.alert}
                    </AlertDescription>
                </Alert>
            )}
        </div>
    )
}

export default GuestAlerts
