export const HomePage = () => {
  return (
    <div className="space-y-6">
      <div className="bg-white rounded-lg shadow-md p-6">
        <h2 className="text-xl font-semibold text-gray-900 mb-4">
          Welcome to AutoClean
        </h2>
        <p className="text-gray-600 mb-4">
          AutoClean is a simple tool that helps you identify and remove temporary or duplicate files from your folders.
        </p>
        <div className="bg-blue-50 border border-blue-200 rounded-md p-4">
          <h3 className="text-sm font-medium text-blue-900 mb-2">Features:</h3>
          <ul className="list-disc list-inside text-sm text-blue-800 space-y-1">
            <li>Detect temporary files (.tmp, .temp, .cache)</li>
            <li>Identify duplicate files</n            <li>Free up disk space automatically</li>
            <li>Safe and efficient cleanup process</li>
          </ul>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-md p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Getting Started</h3>
        <p className="text-gray-600">
          Select a folder to scan and let AutoClean identify files that can be safely removed.
        </p>
      </div>
    </div>
  )
}

export default HomePage