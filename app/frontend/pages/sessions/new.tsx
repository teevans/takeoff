import { LoginForm } from "@/pages/sessions/login-form.tsx"
import GuestLayout from "@/pages/layouts/guest-layout.tsx";
function New() {
    return (
        <div className="flex min-h-svh w-full items-center justify-center p-6 md:p-10">
            <div className="w-full max-w-sm">
                <LoginForm />
            </div>
        </div>
    )
}

New.layout = (page: React.ReactNode) => <GuestLayout children={page}/>

export default New